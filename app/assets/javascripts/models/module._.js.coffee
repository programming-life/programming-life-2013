# Baseclass of all modules. Defines basic behaviour like undo and redo 
# mechanisms and solving of differential equations
class Model.Module

	# Constructor for module
	#
	# @param params [Object] parameters for this module
	# @param step [Function] the step function
	# @param substrates [Object] the substrates for this module
	#
	constructor: ( params, step ) -> 
		@_creation = Date.now()
		@_tree = new UndoTree()

		for key, value of params
			((key) => 
				Object.defineProperty( @ , "_#{key}",
					value: value
					configurable: false
					enumerable: false
					writable: true
				)

				Object.defineProperty( @ , key,
					set: ( param ) ->
						@_addMove(key, @["_#{key}"], param)
						@_do(key, param)
					get: ->
						return @["_#{key}"]
					enumerable: true
					configurable: false
				)
			) key

		Object.defineProperty( @, '_step',
			get: ->
				return step
		)
		
		Object.defineProperty( @, 'amount',
			get: ->
				return @starts.name
			set: (value) ->
				@starts.name = value
		)
		
		Object.seal( @ )
		
	# Gets the substrate start value
	#
	# @param substrate [String] the substrate name
	# @return [Integer] the value
	#
	getSubstrate: ( substrate, value ) ->
		return @_substrates[ substrate ] ? false	
		
	# Adds the substrate to the start values
	#
	# @param substrate [String] the substrate name
	# @param value [Integer] the value
	#
	setSubstrate: ( substrate, value ) ->
		@_substrates[ substrate ] = value
		
	# Runs the step function in the correct context
	# 
	# @param t [Integer] the current time
	# @param substrates [Array] the substrate values
	# @return [any] returns the value step function is returning
	#
	step : ( t, substrates, mu ) ->
		return @_step.call( @, t, substrates, mu )
		
	# Tests if substrates are available
	# @param substrates [Object] the available subs
	# @param tests... [String] comma delimited list of strings to test
	# @return [Boolean] true if all are available
	#
	_test : ( substrates, tests... ) ->
		
		# TODO notification if fails
		return not _( tests ).some( 
			( anon ) -> return not ( substrates[anon]? ) 
			# TODO what to do when it goes below 0
		)
	# Applies a change to the parameters of the module
	#
	# @param [String] key The changed property
	# @param [val] value The value of the changed property
	_do : ( key, value ) ->
		@["_#{key}"] = value

	# Adds a move to the undotree
	#
	# @param [String] key, the changed property
	# @param [val] value, the value of the changed property 
	_addMove: ( key, value, param ) ->
		object = [key, value, param]
		@_tree.add(object)

	# Undoes the most recent move
	undo: ( ) ->
		[key, value, param] = @_tree.undo()
		@_do(key, value)

	# Redoes the most recently undone move
	redo : ( ) ->
		[key, value, param] = @_tree.redo()
		@_do(key, param)

(exports ? this).Model.Module = Model.Module
