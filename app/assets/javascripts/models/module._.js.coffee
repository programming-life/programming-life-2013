# Baseclass of all modules. Defines basic behaviour like undo and redo 
# mechanisms and solving of differential equations. 
#
class Model.Module

	# Constructor for module
	#
	# @param params [Object] parameters for this module
	# @param step [Function] the step function
	#
	constructor: ( params, step ) -> 
		
		@_tree = new UndoTree()
		creation = Date.now()

		for key, value of params
		
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
						@_do( "_#{key}", param )
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
		)
		
		Object.defineProperty( @, 'amount',
			# @property [Integer] the amount of this substrate at start
			get: ->
				return @getSubstrate 'name'
			set: ( value ) ->
				@setSubstrate 'name', value
		)
		
		Object.defineProperty( @, 'creation',
			# @property [Date] the creation date
			get: ->
				return creation
		)

		Object.seal @
						
		context = @
		addmove = ( caller, key, value, param ) ->
			unless caller isnt context
				@_addMove key, value, param
						
		Model.EventManager.on( 'module.set.property', @, addmove )
		Model.EventManager.trigger( 'module.creation', @, [ creation ] )	
		
		Object.seal( @ )
		
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
	# @todo what to do when value is below 0?
	# @param substrates [Object] the available subs
	# @param tests... [String] comma delimited list of strings to test
	# @return [Boolean] true if all are available
	#
	_test : ( substrates, tests... ) ->
		
		result = not _( tests ).some( 
			( anon ) -> return not ( substrates[anon]? ) 
		)
		
		unless result
			Model.EventManager.trigger( 'notification', @, [ 'module', 'test', [ substrates, tests ] ] )	
		
		return result
		
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
	_addMove: ( key, value, param ) ->
		@_tree.add [ key, value, param ]
		return this

	# Undoes the most recent move
	#
	# @returns [self] for chaining
	#
	undo: ( ) ->
		result = @_tree.undo()
		console.log "I would like to undo: ", result
		if result isnt null
			[ key, value, param ] = result
			@_do( key, value )
		return this

	# Redoes the most recently undone move
	#
	# @returns [self] for chaining
	#
	redo : ( ) ->
		result = @_tree.redo()
		console.log "I would like to redo: ", result
		if result isnt null
			[ key, value, param ] = result
			@_do( key, param )
		return this

(exports ? this).Model.Module = Model.Module
