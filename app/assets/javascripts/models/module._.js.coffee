# Baseclass of all modules. Defines basic behaviour like undo and redo 
# mechanisms and solving of differential equations. 
#
class Model.Module

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
	
		params = _( params ).defaults( {
			id: _.uniqueId "client:#{this.constructor.name}:"
			creation: Date.now()
		} )

		for key, value of params
		
			value = parseFloat( value ) if _( value ).isString() and !isNaN( value )
			# The function to create a property out of param
			#
			# @param key [String] the property name
			#
			( ( key ) => 
			
				# This defines the private value.
				Object.defineProperty( @ , "_#{key}",
					value: value
					configurable: false
					enumerable: false
					writable: true
				)

				# This defines the public functions to change
				# those values.
				Object.defineProperty( @ , key,
					set: ( param ) ->
						console.log "I am setting #{key}", @["_#{key}"], param
						Model.EventManager.trigger( 'module.set.property', @, [ "_#{key}", @["_#{key}"], param ] )
						@[ "_#{key}"] = param
					get: ->
						return @["_#{key}"]
					enumerable: true
					configurable: false
				)
				
			) key

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
				return @getSubstrate 'name'
				
			set: ( value ) ->
				@setSubstrate 'name', value
				
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

		Object.seal @
					
		# Bind the events
		context = @
		addmove = ( caller, key, value, param ) ->
			unless caller isnt context
				@_addToTree key, value, param
						
		Model.EventManager.on( 'module.set.property', @, addmove )
		Model.EventManager.trigger( 'module.creation', @, [ @creation, @id ] )	
		
	# Extracts id data from id
	#
	# @param id [Object,Number,String] id containing id data
	# @return [Object] extracted id data
	@extractId: ( id ) ->
		return id if _( id ).isObject()
		return { id: id, origin: "server" } if _( id ).isNumber()
		return null unless _( id ).isString()
		data = id.split( ':' )
		return { id: parseInt( data[0] ), origin: "server" } if data.length is 1
		return { id: parseInt( data[2] ), origin: data[0] }
		
	# 
	#
	isLocal : () ->
		return Model.Module.extractId( @id ).origin isnt "server"
		
	# Gets the substrate start value
	#
	# @param substrate [String] the substrate name
	# @return [Integer] the value
	#
	getSubstrate: ( substrate ) ->
		return @starts[ substrate ] ? false	
		
	# Sets the substrate to the start values
	#
	# @param substrate [String] the substrate name
	# @param value [Integer] the value
	# @returns [self] for chaining
	#
	setSubstrate: ( substrate, value ) ->
		Model.EventManager.trigger( 'module.set.substrate', @, [ substrate, @starts[ substrate ] ? undefined, value ] )	
		
		changes = { }
		changes[ substrate ] = value
		changed = _( { } ).extend @starts, changes
		
		@starts = changed
		return this
		
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
			Model.EventManager.trigger( 'notification', @, [ 'module', 'test', [ compounds, tests ] ] )	
		
		return result
		
	# Ensures test to be true or notifies with message
	#
	# @param test [Function] function in a module to run
	# @param message [String] string to display when it fails
	# @return [Boolean] true if test succeeded
	#
	_ensure : ( test, message = '' ) ->
		
		unless test
			Model.EventManager.trigger( 'notification', @, [ 'module', 'ensure', [ message ] ] )	
		
		return test
		
	# Applies a change to the parameters of the module
	#
	# @param [String] key The changed property
	# @param [val] value The value of the changed property
	# @returns [self] for chaining
	#
	_do : ( key, value ) ->
		console.log "Doing: #{key}", @[ key ], value
		@[ key ] = value
		console.log "Done: #{key}", @[ key ], value
		return this

	# Adds a move to the undotree
	#
	# @param [String] key, the changed property
	# @param [val] value, the value of the changed property 
	# @returns [self] for chaining
	#
	_addToTree: ( key, value, param ) ->
		func = (key, value ) => 
			@["#{key}"] = value
		todo = _( func ).bind(@, key, param)
		redo = _( func ).bind(@, key, value)
		action = new Model.Action(@, todo, redo)

		@_tree.add(action)
		return this

	# Undoes the most recent move
	#
	# @returns [self] for chaining
	#
	undo: ( ) ->
		action = @_tree.undo()
		console.log "I would like to undo: ", action
		if action isnt null
			action.undo()
		return this

	# Redoes the most recently undone move
	#
	# @returns [self] for chaining
	#
	redo : ( ) ->
		action = @_tree.redo()
		console.log "I would like to redo: ", action
		if action isnt null
			action.redo()
		return this
		
	# Serializes a module
	# 
	# @param to_string [Boolean] Stringifies object if try, default true
	# @return [String,Object] JSON Object or String
	#
	serialize : ( to_string = on ) ->
	
		parameters = {}
		for parameter in Object.keys( @ )
			parameters[parameter] = @[parameter]
			
		type = @constructor.name
		
		result = { 
			parameters: parameters
			type: type 
			step: @_step.toString() if type is "Module" and @_step?
		}
		
		return JSON.stringify( result )  if to_string
		return result
		
	# Tries to save a module
	#
	save : ( cell = 1 ) ->
		
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
				
				# Define the parameters set function, so we can resuse it
				update_parameters = () =>
				
					params = []
					for key, value of serialized_data.parameters
						params.push
							key: key
							value: value
							
					module_parameters_data =
						module_parameters: params
						
					console.log module_parameters_data
					$.ajax( @url, { data: module_parameters_data, type: 'PUT' } )
						.done( ( data ) =>  
							# Updated 
						)
						
						.fail( ( data ) => 
							Model.EventManager.trigger( 
								'notification', @, [ 'module', 'save', [ 'update parameters', data, module_parameters_data ] ] )	
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
							Model.EventManager.trigger( 
								'notification', @, [ 'module', 'save', [ 'create instance', data, module_instance_data ] ] )	
						)
				
				# This is the update
				else
					# For module instances only parameters can chane
					update_parameters() 
			)
			
			.fail( ( data ) => 
				Model.EventManager.trigger( 
					'notification', @, [ 'module', 'save', [ 'get template', data, module_template_data ] ] )	
			)
		
	# Deserializes a module
	# 
	# @param serialized [Object,String] the serialized object
	# @todo Safer Eval function
	# @return [Model.Module] the module
	#
	@deserialize : ( serialized ) ->
		
		serialized = JSON.parse( serialized ) if _( serialized ).isString()
		fn = ( window || @ )["Model"]
		return new fn[ serialized.type ]( serialized.parameters ) unless serialized.type is "Module"
		
		# If we are an arbitrary module, we will need the step function
		step = null
		eval( "step = #{serialized.step}" ) if serialized.step?
		return new fn[ serialized.type ]( serialized.parameters, step )
		
	@load : ( module_id, cell, callback ) ->
		module = new Model.Module( { id: module_id } )
		$.get( module.url, { all: true } )
			.done( ( data ) =>
				result = Model.Module.deserialize( data )
				
				console.log result
				cell.add result
				callback.apply( @, result ) if callback?
			)
	
		

(exports ? this).Model.Module = Model.Module
