# Baseclass of all modules. 
#
class Model.Module extends Helper.Mixable

	@include Mixin.DynamicProperties
	@include Mixin.EventBindings

	# Constructor for module
	#
	# @param params [Object] parameters for this module
	# @param step [Function] the step function
	#
	constructor: ( params = {}, step ) -> 

		Object.defineProperty( @ , "_tree",
			value: new Model.UndoTree()
			configurable: false
			enumerable: false
			writable: true
		)
			
		Object.defineProperty( @, '_step',
			
			# @property [Function] the step function
			get: ->
				return step
				
			configurable: false
			enumerable: false
		)
		
		Object.defineProperty( @, 'amount',
			
			# @property [Integer] the amount of this substrate at start
			get: ->
				return @getCompound 'name'
				
			set: ( value ) ->
				@setCompound 'name', value
				
			configurable: false
			enumerable: false
		)
		
		Object.defineProperty( @, 'url',
			
			# @property [String] the url for this model
			get : -> 
				data = Model.Module.extractId( @id )
				return "/module_instances/#{ data.id }.json" if data.origin is "server"
				return '/module_instances.json'
			
			configurable: false
			enumerable: false
		)
		
		@_allowBindings()
		@_defineProps(  
			_( params ).defaults( {
				id: _.uniqueId "client:#{this.constructor.name}:"
				creation: Date.now()
			} ),
			'module.set.property'
		)

		Object.seal @
					
		# Bind the events
		context = @
		addmove = ( caller, key, value, param ) ->
			unless caller isnt context
				@_addMove key, value, param
						
		@_bind( 'module.set.property', @, addmove )
		Model.EventManager.trigger( 'module.creation', @, [ @creation, @id ] )	
		
	# Extracts id data from id
	#
	# @param id [Object,Number,String] id containing id data
	# @return [Object] extracted id data
	#
	@extractId: ( id ) ->
		return id if _( id ).isObject()
		return { id: id, origin: "server" } if _( id ).isNumber()
		return null unless _( id ).isString()
		data = id.split( ':' )
		return { id: parseInt( data[0] ), origin: "server" } if data.length is 1
		return { id: parseInt( data[2] ), origin: data[0] }
		
	# Returns true if this is a local instance
	# 
	# @return [Boolean] true if local, false if synced instance
	#
	isLocal : () ->
		return Model.Module.extractId( @id ).origin isnt "server"
		
	# Gets the compounds start value
	#
	# @param compound [String] the compound name
	# @return [Integer] the value
	#
	getCompound: ( compound ) ->
		return @starts[ compound ] ? 0	
		
	# Gets the metabolite start value (alias for getCompound)
	#
	# @param metabolite [String] the metabolite name
	# @return [Integer] the value
	#
	getMetabolite: ( metabolite ) ->
		return @getCompound( metabolite )
		
	# Gets the substrate start value (alias for getCompound)
	#
	# @param substrate [String] the substrate name
	# @return [Integer] the value
	#
	getSubstrate: ( substrate ) ->
		return @getCompound( substrate )
		
	# Gets the product start value (alias for getCompound)
	#
	# @param product [String] the product name
	# @return [Integer] the value
	#
	getProduct: ( product ) ->
		return @getCompound( product )
		
	# Sets the compound to the start values
	#
	# @param compound [String] the compound name
	# @param value [Integer] the value
	# @return [self] for chaining
	#
	setCompound: ( compound, value ) ->
		Model.EventManager.trigger( 'module.set.compound', @, [ compound, @starts[ compound ] ? 0, value ] )	
		
		changes = { }
		changes[ compound ] = value
		changed = _( { } ).extend @starts, changes
		
		@starts = changed
		return this
		
	# Sets the metabolite to the start values (alias for setCompound)
	#
	# @param metabolite [String] the metabolite name
	# @param value [Integer] the value
	# @return [self] for chaining
	#
	setMetabolite: ( metabolite, value ) ->
		return @setCompound( metabolite, value )
		
	# Sets the substrate to the start values (alias for setCompound)
	#
	# @param substrate [String] the substrate name
	# @param value [Integer] the value
	# @return [self] for chaining
	#
	setSubstrate: ( substrate, value ) ->
		return @setCompound( substrate, value )
		
	# Sets the product to the start values (alias for setCompound)
	#
	# @param product [String] the product name
	# @param value [Integer] the value
	# @return [self] for chaining
	#
	setProduct: ( product, value ) ->
		return @setCompound( product, value )
		
	# Runs the step function in the correct context
	# 
	# @param t [Integer] the current time
	# @param substrates [Array] the substrate values
	# @return [any] returns the value step function is returning
	#
	step : ( t, substrates, mu ) ->
		Model.EventManager.trigger( 'module.before.step', @, [ t, substrates, mu ] )
		results = @_step.call( @, t, substrates, mu )
		Model.EventManager.trigger( 'module.after.step', @, [ t, substrates, mu, results ] )
		return results
		
	# Tests if substrates are available
	#
	# @todo What to do when value is below 0?
	# @param substrates [Object] the available subs
	# @param tests... [String] comma delimited list of strings to test
	# @return [Boolean] true if all are available
	#
	_test : ( compounds, tests... ) ->
		
		result = not _( _( tests ).flatten() ).some( 
			( test ) -> return not ( compounds[ test ]? ) 
		)
		
		unless result
			Model.EventManager.trigger( 'notification', @, 
				[ 
					# section, method, message-id
					'module', 'test', "#{ @constructor.name }:#{ @name }:#{ id ? 1 }",
					"I need compounds in #{ @constructor.name }:#{ @name } but they are not available. #{ message ? '' }",
					[ compounds, tests ] 
				] 
			)	
		
		return result
		
	# Ensures test to be true or notifies with message
	#
	# @param test [Function] function in a module to run
	# @param message [String] string to display when it fails
	# @return [Boolean] true if test succeeded
	#
	_ensure : ( test, message ) ->
		
		unless test
			Model.EventManager.trigger( 'notification', @, 
				[ 
					'module', 'ensure', "#{ @constructor.name }:#{ @name }:#{ id ? 1 }",
					"In #{ @constructor.name }:#{ @name } an ensure failed: #{ message ? '' }",
					[] 
				] 
			)		
		
		return test
		
	# Applies a change to the parameters of the module
	#
	# @param [String] key The changed property
	# @param [val] value The value of the changed property
	# @return [self] for chaining
	#
	_do : ( key, value ) ->
		@[ key ] = value
		return this

	# Adds a move to the undotree
	#
	# @param [String] key, the changed property
	# @param [val] value, the value of the changed property 
	# @return [self] for chaining
	#
	_addMove: ( key, value, param ) ->
		@_tree.add [ key, value, param ]
		return this

	# Undoes the most recent move
	#
	# @return [self] for chaining
	#
	undo: ( ) ->
		result = @_tree.undo()
		if result isnt null
			[ key, value, param ] = result
			@_do( key, value )
		return this

	# Redoes the most recently undone move
	#
	# @return [self] for chaining
	#
	redo : ( ) ->
		result = @_tree.redo()
		if result isnt null
			[ key, value, param ] = result
			@_do( key, param )
		return this
		
	# Serializes a module
	# 
	# @param to_string [Boolean] Stringifies object if try, default true
	# @return [String,Object] JSON Object or String
	#
	serialize : ( to_string = on ) ->
	
		parameters = {}
		for parameter in @_dynamicProperties 
			parameters[ parameter ] = @[ parameter ]
			
		type = @constructor.name
		
		result = { 
			name: @name
			parameters: parameters
			type: type 
			amount: @amount
			step: @_step.toString() if type is "Module" and @_step?
		}
		
		return JSON.stringify( result )  if to_string
		return result
		
	# Tries to save a module
	#
	# @todo if dynamic, also needs to save the template
	# @todo error handling
	#
	save : ( cell ) ->
		
		serialized_data = @serialize( false )
		
		# if dynamic, also needs to save the template
		# if ( serialized_data.step? )
		# 	build template blabla
			
		# First get the template for this instance
		data =
			redirect: 'template'
			type: serialized_data.type
			
		$.get( @url, data )
		
			.done( ( module_template ) =>
		
				# Next map data for this object
				module_instance_data =
					module_instance:
						id: serialized_data.id unless @isLocal()
						module_template_id: module_template.id
						cell_id: cell
						name: serialized_data.name
						amount: serialized_data.amount
				
				# Define the parameters set function, so we can resuse it
				update_parameters = () =>
				
					params = []
					for key, value of serialized_data.parameters
						params.push
							key: key
							value: value
							
					module_parameters_data =
						module_parameters: params
						
					$.ajax( @url, { data: module_parameters_data, type: 'PUT' } )
						.done( ( data ) =>  
							# Updated 
						)
						
						.fail( ( data ) => 
							
							Model.EventManager.trigger( 'notification', @, 
								[ 
									'module', 'save', "#{ @constructor.name }:#{ @name }:#{ serialized_data.name }",
									"While saving parameters for #{ serialized_data.name } an error occured: #{ data ? '' }",
									[ 
										'update parameters',
										data,
										module_instance_data, 
										module_parameters_data, 
									] 
								] 
							)		
						)
				
				# This is the create
				if @isLocal()
				
					$.post( @url, module_instance_data )
						.done( ( data ) => 
							
							# Lets save those results first
							@id = data.id
							
							# And now we need to store those parameters
							update_parameters()
						)
						
						.fail( ( data ) => 
						
							Model.EventManager.trigger( 'notification', @, 
								[ 
									'module', 'save', "#{ @constructor.name }:#{ @name }:#{ module_instance_data.name }",
									"While creating module instance #{ serialized_data.name } an error occured: #{ data ? '' }",
									[ 
										'create instance',
										data,
										module_instance_data, 
										module_parameters_data
									] 
								] 
							)		
						)
				
				# This is the update
				else
					# For module instances only parameters can chane
					update_parameters() 
			)
			
			.fail( ( data ) => 
			
				Model.EventManager.trigger( 'notification', @, 
					[ 
						'module', 'save', "#{ @constructor.name }:#{ @name }:#{ serialized_data.type }",
						"While retrieving module template #{ serialized_data.type } an error occured: #{ data ? '' }",
						[ 
							'get instance',
							data,
							serialized_data
						] 
					] 
				)		
			)
		
	# Deserializes a module
	# 
	# @param serialized [Object,String] the serialized object
	# @todo Safer Eval function
	# @return [Model.Module] the module
	#
	@deserialize : ( serialized ) ->
		
		serialized = JSON.parse( serialized ) if _( serialized ).isString()
		serialized.parameters.name = serialized.parameters.name ? serialized.name
		fn = ( window || @ )["Model"]
		return new fn[ serialized.type ]( serialized.parameters ) unless serialized.type is "Module"
		
		# If we are an arbitrary module, we will need the step function
		step = null
		eval( "step = #{serialized.step}" ) if serialized.step?
		return new fn[ serialized.type ]( serialized.parameters, step )
		
	# Loads a module
	# 
	# @param module_id [Integer] the id of the module
	# @param cell [Model.Cell] the cell to load to
	# @param callback [Function] function to call on completion
	#
	@load : ( module_id, cell, callback ) ->
		module = new Model.Module( { id: module_id } )
		$.get( module.url, { all: true } )
			.done( ( data ) =>
				result = Model.Module.deserialize( data )
				cell.add result
				callback.apply( @, result ) if callback?
			)
	
(exports ? this).Model.Module = Model.Module
