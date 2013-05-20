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
		
		@_defineProperties( params, step, metadata )
					
		@_bind( 'module.set.property', @, @onPropertySet )
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
		
		@_defineGetters( step, metadata )
		@_defineAccessors()
		
		@_propertiesFromParams(  
			_( params ).defaults( {
				id: _.uniqueId "client:#{this.constructor.name}:"
				creation: Date.now()
				starts: {}
			} ),
			'module.set.property'
		)

		Object.seal @ 
		return this
		
	# Defines the getters
	#
	# @return [self] chainable self
	#
	_defineGetters: ( step, metadata ) ->
		
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
		
	# Triggered when a property is set
	#
	# @param caller [any] the originating property
	# @param action [Model.Action] the action invoked
	#
	onPropertySet: ( caller, action ) =>
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
		@_trigger( 'module.set.compound', @, [ compound, @starts[ compound ] ? 0, value ] )	
		
		@starts[ compound ] = value
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
	step: ( t, substrates, mu ) ->
		@_trigger( 'module.before.step', @, [ t, substrates, mu ] )
		results = @_step.call( @, t, substrates, mu )
		@_trigger( 'module.after.step', @, [ t, substrates, mu, results ] )
		return results
		
	# Test function to override by submodules
	#
	# @param compounds [Object] the available subs
	#
	test: ( compounds ) ->
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
		
		unless result
			missing = _( _( tests ).flatten() ).difference( _( compounds ).keys() )
			@_notificate( 
				@, @, 
				"module.test.#{ @name }",
				"I need #{ missing } in order to function correctly",
				[ compounds, tests ],
				Model.Module.Notification.Error
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
			amount: @amount? 0
			step: @_step.toString() if type is "Module" and @_step?
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
			
		promise = $.ajax( @url, { data: module_parameters_data, type: 'PUT' } )
		
		promise.done( ( data ) =>
			@_notificate( @, @, 
				"module.save.#{ @name }",
				"Succesfully saved #{ @name }",
				[ 'update parameters' ],
				Model.Module.Success
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
				Model.Module.Error
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
					Model.Module.Error
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
					]
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
				cell.add result
				callback.apply( @, result ) if callback?
				
				module._notificate(
					cell, module, 
					"module.load.:#{module_id}",
					"Succesfully loaded #{module.name}",
					[ 'load' ],
					Model.Module.Success
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
					Model.Module.Error
				)	
			)
			
		return promise
