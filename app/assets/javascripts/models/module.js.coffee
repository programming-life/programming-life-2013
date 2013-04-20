# Baseclass of all modules. Defines basic behaviour like undo and redo 
# mechanisms and solving of differential equations
class Module
	# Constructor for module
	#
	# @param [Object] params, parameters for this module
	# @param [Function] step the step function
	constructor: ( params, step ) -> 
		@_creation = Date.now()
		@_history = []
		@_future = []

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

		Object.defineProperty( @, 'step',
			get: ->
				return step
		)
		
		Object.seal( @ )
		
	# Runs the step function in the correct context
	# 
	# @param [Integer] t the current time
	# @param [Array] substrates the substrate values
	# @returns [any] returns the value step function is returning
	step : ( t, substrates ) ->
		@step.apply( @, t, substrates )

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



