# Baseclass of all modules. Defines basic behaviour like undo and redo 
# mechanisms and solving of differential equations
class Module

	# Constructor for module
	#
	# @param params [Object] parameters for this module
	# @param step [Function] the step function
	# @param substrates [Object] the substrates for this module
	#
	constructor: ( params, step, substrates = {} ) -> 
		@_creation = Date.now()
		@_history = []
		@_future = []
		@_substrates = substrates

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
						@_clearFuture()
						@_pushHistory(key, @["_#{key}"])
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
			( anon ) -> return not substrates[anon]? 
		)

	# Pushes a move onto the history stack, and notifies Main of this move.
	#
	# @param [String] key, the changed property
	# @param [val] value, the value of the changed property 
	_pushHistory: ( key, value ) ->
		@_history.push [key, value]
		Main.pushHistory('modify', @)

	# Pops a move of the history stack and applies it. Calls _pushFuture on the 
	# changed values.
	#
	popHistory: ( ) ->
		if @_history.length > 0
			[key, value] = @_history.pop()
			@_pushFuture(key, @[key])
			@["_#{key}"] = value

	# Pushes a move onto the future stack, and notifies Main of this move.
	#
	# @param [String] key, the changed property
	# @param [val] value, the value of the changed property 
	_pushFuture: ( key, value ) ->
		@_future.push [key, value]
		Main.pushFuture('modify', @)

	# Pops a move of the future stack and applies it. Calls _pushHistory on the 
	# changed values.
	#
	popFuture: ( ) ->
		if @_future.length > 0
			[key, value] = @_future.pop()		
			@_pushHistory(key, @[key])
			@["_#{key}"] = value

	# Clears the future stack. Should be called when a move is actually done.
	#
	_clearFuture: ( ) ->
		@_future.length = 0

(exports ? this).Module = Module



