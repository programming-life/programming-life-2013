# Baseclass of all modules. Defines basic behaviour like undo and redo 
# mechanisms and solving of differential equations
class Model.Module

	# Constructor for module
	#
	# @param params [Object] parameters for this module
	# @param step [Function] the step function
	# @param substrates [Object] the substrates for this module
	#
	constructor: ( params, step, substrates = {} ) -> 
		@_creation = Date.now()
		@_substrates = substrates
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
						@_pushHistory(key, @["_#{key}"], param)
						@["_#{key}"] = param
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
		
		Object.defineProperty( @, 'substrates',
			get: ->
				return @_substrates
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
	step : ( t, substrates ) ->
		return @_step.call( @, t, substrates )
		
	# Tests if substrates are available
	# @param substrates [Object] the available subs
	# @param tests... [String] comma delimited list of strings to test
	# @return [Boolean] true if all are available
	#
	_test : ( substrates, tests... ) ->
		
		# TODO notification if fails
		return not _( tests ).some( 
			( anon ) -> return not ( substrates[anon]? and substrates[anon] >= 0 )
		)

	# Pushes a move onto the history stack, and notifies Main of this move.
	#
	# @param [String] key, the changed property
	# @param [val] value, the value of the changed property 
	_pushHistory: ( key, value, param ) ->
		object = [key, value, param]
		@_tree.add(object)

	# Pops a move of the history stack and applies it. Calls _pushFuture on the 
	# changed values.
	#
	popHistory: ( ) ->
		[key, value, param] = @_tree.undo()
		@["_#{key}"] = value

	# Pops a move of the future stack and applies it. Calls _pushHistory on the 
	# changed values.
	#
	popFuture: ( ) ->
		[key, value, param] = @_tree.redo()
		@["_#{key}"] = param

(exports ? this).Model.Module = Model.Module



