# Baseclass of all modules. 
#
# @concern Mixin.DynamicProperties
# @concern Mixin.EventBindings
# @concern Mixin.TimeMachine
#
class Model.Module extends Helper.Mixable

	@concern Mixin.DynamicProperties
	@concern Mixin.EventBindings
	@concern Mixin.TimeMachine

	# Constructor for module
	#
	# @param params [Object] parameters for this module
	# @param step [Function] the step function
	#
	constructor: ( params = {}, step, metadata = {} ) -> 
		
		@_allowTimeMachine()
		@_allowEventBindings()
		
		if params.amount?
			amount = params.amount
			delete params.amount
			starts = params.starts ? { name: amount }
			starts.name = amount
			params.starts = starts
		
		@_defineProperties( params, step, metadata )
		
		action = @_createAction( "Created #{this.constructor.name}:#{this.name}")
		@tree.setRoot( new Model.Node(action, null) )
					
		@_bind( 'module.property.changed', @, @onActionDo )
		@_bind( 'module.set.compound', @, @onActionDo )
		@_trigger( 'module.creation', @, [ @creation, @id ] )	
		
	# Defines All the properties
	#
	# @return [self] chainable self
	#
	_defineProperties: ( params, step, metadata ) ->
				
		properties = metadata.properties ? { }
		properties.parameters = (properties.parameters ? [])
		properties.parameters.push 'amount'
		metadata.properties = properties
		
		@_defineGetters( params, step, metadata )
		@_defineAccessors()
		@_defineDynamicProperties( params )

		Object.seal @ 
		return this
		
	# Defines the getters
	#
	# @return [self] chainable self
	#
	_defineGetters: ( params, step, metadata ) ->
		
		@_nonEnumerableGetter( '_step', () -> return step )
		@_nonEnumerableGetter( 'metadata', () -> return metadata )
		@_nonEnumerableGetter( 'url', () ->
				data = Model.Module.extractId( @id )
				return "/module_instances/#{ data.id }.json" if data.origin is "server"
				return '/module_instances.json'
		)

		return this
		
	# Defines the accessors
	#
	# @return [self] chainable self
	#
	_defineAccessors: () ->
	
		Object.defineProperty( @, 'amount',
			
			# @property [Integer] the amount of this substrate at start
			get: ->
				return @getCompound 'name'
				
			set: ( value ) ->
				@setCompound 'name', value
				
			configurable: false
			enumerable: false
		)
		
	#
	#
	_defineDynamicProperties: ( params ) ->
		@_propertiesFromParams(  
			_( params ).defaults( {
				id: _.uniqueId "client:#{this.constructor.name}:"
				creation: Date.now()
				starts: {}
			} ),
			'module.property.changed'
		)
		return this
		
	# Triggered when an action is done
	#
	# @param caller [any] the originating property
	# @param action [Model.Action] the action invoked
	#
	onActionDo: ( caller, action ) =>
		if caller is @
			@addUndoableEvent( action )

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
		console.log(compound, value)
		
		return this if  @starts[ compound ] is value
		
		todo = _( ( compound, value ) -> @starts[ compound ] = value ).bind( @, compound, value )
		undo = _( ( compound, value ) -> @starts[ compound ] = value ).bind( @, compound, @starts[ compound ] )
		
		action = new Model.Action( 
			@, todo, undo, 
			"Change initial value for #{@[compound] ? compound} from #{ @starts[ compound ] } to #{value}" 
		)
		action.do()
		
		@_trigger( 'module.set.compound', @, [ action ] )	
		
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

	# Returns a module's full type string
	#
	# @return [String] the type string
	#
	getFullType: ( direction = @direction, type = @type, placement = @placement ) ->
		switch @constructor.name
			when 'Transporter'
				res = 'Transporter'
				if direction is Model.Transporter.Inward
					res += '-inward'
				else if direction is Model.Transporter.Outward
					res += '-outward'
			when 'Metabolite'
				res = 'Metabolite'

				if type is Model.Metabolite.Substrate
					res += '-substrate'
				else if type is Model.Metabolite.Product
					res += '-product'

				if placement is Model.Metabolite.Inside
					res += '-inside'
				else if placement is Model.Metabolite.Outside
					res += '-outside'
			else
				res = @constructor.name

		return res
		
	# Runs the step function in the correct context
	# 
	# @param t [Integer] the current time
	# @param substrates [Array] the substrate values
	# @return [any] returns the value step function is returning
	#
	step: ( t, substrates, mu ) ->
		@_trigger( 'module.before.step', @, [ t, substrates, mu ] )
		results = @_step.call( @, t, substrates, mu )
		@_trigger( 'module.after.step', @, [ t, substrates, mu, results ] )
		return results
		
	# Listify a list
	#
	# @todo make this a helper function
	#
	_listify: ( items, bind = 'and', nothing = 'nothing' ) ->
		return nothing if items.length is 0
		return items[0] if items.length is 1
		return ( _( items ).without ( last = _( items ).last() ) ).join(', ') + " #{bind} #{last}"
		
	# Test if compounds are available. Automatically maps keys to actual properties.
	#
	# @param compounds [Object] the available subs
	# @param keys... [String] comma delimited list of keys that should be mapped to tests
	# @return [Boolean] true if all are available
	#
	test: ( compounds, keys... ) ->
		
		tests = _( _( keys ).flatten() ).map( ( t ) => @[ t ] )
		unless @_test( compounds, tests )
			missing = _( _( tests ).flatten()  ).difference( _( compounds ).keys() )
			@_notificate( 
				@, @, 
				"module.test.#{ @name }",
				"I need #{ @_listify missing } #{ message ? '' }",
				[ missing ],
				Model.Module.Notification.Error
			)
			return false
	
		return true
		
	# Tests if substrates are available
	#
	# @param compounds [Object] the available subs
	# @param tests... [String] comma delimited list of strings to test
	# @return [Boolean] true if all are available
	#
	_test: ( compounds, tests... ) ->
		
		result = not _( _( tests ).flatten() ).some( 
			( test ) -> return not ( compounds[ test ]? ) 
		)
		
		return result
		
	# Ensures test to be true or notifies with message
	#
	# @param test [Boolean] boolean in a module to run
	# @param message [String] string to display when it fails
	# @return [Boolean] true if test succeeded
	#
	_ensure : ( test, message ) ->
		
		unless test
			@_notificate( @, @, 
				"module.ensure.#{ @name }",
				"In #{ @constructor.name }:#{ @name } an ensure failed: #{ message ? 'No additional message.' }",
				[],
				Model.Module.Notification.Error
			)		
		
		return test
		
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
			amount: @amount ? 0
			step: @_step.toString() if type is "Module" and @_step?
			id: @id
		}
		
		return JSON.stringify( result )  if to_string
		return result
		
	# Gets the module template for a type
	#
	# @param type [String] type to get for
	# @return [jQuery.Promise] promise request
	#
	_getModuleTemplate: ( type ) ->
		data =
			redirect: 'template'
			type: type
			
		return $.get( @url, data )
		
	# Gets the module instance data for instance, template and cell
	#
	# @param instance [Object] instance data to get for
	# @param template [Object] template data to get for
	# @param cell [Integer] cell id to get for
	# @return [Object] combined instance data
	#
	_getModuleInstanceData: ( instance, template, cell ) ->
		result = {
			module_instance:
				module_template_id: template.id
				cell_id: cell
				name: instance.name
				amount: instance.amount
		}
		result.id = instance.id unless @isLocal()
		return result
		
	# Updates the parameters givin
	#
	# @param prameters [Object] parameters to update
	# @return [jQuery.Promise] the update promise
	#
	_updateParameters: ( parameters ) ->
		
		@_notificate( @,  @, 
			"module.save.#{ @name }",
			"Saving #{ @name }...",
			[ 'update parameters' ],
			Model.Module.Notification.Info
		)		
	
		params = []
		for key, value of parameters
			params.push
				key: key
				value: value
			
		module_parameters_data =
			module_parameters: params
			module_instance:
				amount: @amount
			
		promise = $.ajax( @url, { data: module_parameters_data, type: 'PUT' } )
		
		promise.done( ( data ) =>
			@_notificate( @, @, 
				"module.save.#{ @name }",
				"Succesfully saved #{ @name }",
				[ 'update parameters' ],
				Model.Module.Notification.Success
			)		
		)
			
		promise.fail( ( data ) => 		
			@_notificate( @, @, 
				"module.save.#{ @name }",
				"While saving parameters for #{ @name } an error occured: #{ JSON.stringify( data ? { message: 'none' } ) }",
				[ 
					'update parameters',
					data,
					module_parameters_data, 
				],
				Model.Module.Notification.Error
			)		
		)
		
		return promise
		
	# Creates a new module from serialized data, template and cell
	#
	# @param instance [Object] instance data to get for
	# @param template [Object] template data to get for
	# @param cell [Integer] cell id to get for
	#
	_create: ( instance, template, cell ) ->
		
		@_notificate( @,  @, 
			"module.save.#{ @name }",
			"Creating #{ @name }...",
			[ 'create instance' ],
			Model.Module.Notification.Info
		)		
		
		module_instance_data = @_getModuleInstanceData( 
			instance, template, cell 
		)
		
		promise = $.post( @url, module_instance_data )
		promise = promise.then( 
		
			# Done
			( data ) => 	
				@id = data.id
				
				@_notificate( @,  @, 
					"module.save.#{ @name }",
					"Succesfully created #{ @name }",
					[ 'create instance' ],
					Model.Module.Notification.Success
				)		
				
			# Fail
			, ( data ) => 		
				@_notificate( @, @ 
					"module.save.#{ @name }",
					"While creating module instance #{ instance.name } an error occured: #{ JSON.stringify( data ? { message: 'none' } ) }",
					[ 
						'create instance',
						data,
						module_instance_data
					],
					Model.Module.Notification.Error
				)		
			)
		
		return promise
		
	# Tries to save a module
	#
	# @todo if dynamic, also needs to save the template
	# @todo error handling
	#
	save: ( cell ) ->
		
		serialized_data = @serialize( false )
		
		# if dynamic, also needs to save the template
		# if ( serialized_data.step? )
		# 	build template blabla
		
		promise = @_getModuleTemplate serialized_data.type
		promise = promise.then( 
		
			# Done
			( module_template ) =>
				
				if not @isLocal()
					return @_updateParameters( serialized_data.parameters ) 
					
				promise = @_create( serialized_data, module_template, cell )
				promise = promise.then( ( data ) =>
					return @_updateParameters serialized_data.parameters
				)
				return promise
				
			# Fail
			, ( data ) => 
				@_notificate( @,  @, 
					"module.save.#{ @name }",
					"While retrieving module template #{ serialized_data.type } an error occured: #{ JSON.stringify( data ? { message: 'none' } ) }",
					[ 
						'get instance',
						data,
						serialized_data
					],
					Model.Module.Notification.Error
				)		
			)
		
		return promise
		
	# Deserializes a module
	# 
	# @param serialized [Object,String] the serialized object
	# @todo Safer Eval function
	# @return [Model.Module] the module
	#
	@deserialize : ( serialized ) ->
		
		serialized = JSON.parse( serialized ) if _( serialized ).isString()
		serialized.parameters.name = serialized.parameters.name ? serialized.name
		serialized.parameters.amount = serialized.parameters.amount ? serialized.amount
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
		promise = $.get( module.url, { all: true } )
		
		promise = promise.then( 
			
			# Done
			( data ) =>
				result = Model.Module.deserialize( data )
				callback.call( @, result ) if callback?
				
				module._notificate(
					cell, module, 
					"module.load.:#{module_id}",
					"Succesfully loaded #{module.name}",
					[ 'load' ],
					Model.Module.Notification.Success
				)	
				
			# Fail
			( data ) =>
			
				module._notificate(
					cell, module, 
					"module.load.:#{module_id}",
					"I am trying to load module #{ module_id } for the cell #{ cell } but an error occured: #{ JSON.stringify( data ? { message: 'none' } ) }",
					[ 
						'load', 
						data, 
						module_id,
						cell
					],
					Model.Module.Notification.Error
				)	
			)
			
		return promise
