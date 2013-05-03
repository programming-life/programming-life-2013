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
						@_addMove(key, @["_#{key}"], param)
						@_do(key, param)
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
				return @starts.name
			set: (value) ->
				@starts.name = value
		)
		
		Object.defineProperty( @, 'creation',
			# @property [Date] the creation date
			get: ->
				return creation
		)

		$(document).trigger('moduleInit', this)
		
		Object.seal( @ )
				
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
	# @returns [self] for chaining
	#
	_do : ( key, value ) ->
		@["_#{key}"] = value
		return this

	# Adds a move to the undotree
	#
	# @param [String] key, the changed property
	# @param [val] value, the value of the changed property 
	# @returns [self] for chaining
	#
	_addMove: ( key, value, param ) ->
		object = [key, value, param]
		@_tree.add(object)
		return this

	# Undoes the most recent move
	#
	# @returns [self] for chaining
	#
	undo: ( ) ->
		[key, value, param] = @_tree.undo()
		@_do(key, value)
		return this

	# Redoes the most recently undone move
	#
	# @returns [self] for chaining
	#
	redo : ( ) ->
		[key, value, param] = @_tree.redo()
		@_do(key, param)
		return this

(exports ? this).Model.Module = Model.Module
