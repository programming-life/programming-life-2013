class Cell

	# The constructor for the cell
	#
	constructor: ( ) ->
		@_creation = Date.now()
		@_modules = []
		@_substrates = {}
	
	# Add module to cell
	#
	# @param [Module] module module to add to this cell
	# @returns [self] chainable instance
	#
	add: ( module ) ->
		@_modules.push module
		@
		
	# Add substrate to cell
	#
	# @param [String] substrate substrate to add
	# @param [Integer] amount amount of substrate to add
	# @returns [self] chainable instance
	#
	add_substrate: ( substrate, amount ) ->
		@_substrates[ substrate ] = amount
		@
		
	# Remove module from cell
	#
	# @param [Module] module module to remove from this cell
	# @returns [self] chainable instance
	#
	remove: ( module ) ->
		@_modules.splice( @_modules.indexOf module, 1 ) #TODO: update to use underscore without
		@
		
	# Removes this substrate from cell
	#
	# @param [String] substrate substrate to remove from this cell
	# @returns [self] chainable instance
	#
	remove_substrate: ( substrate ) ->
		delete @_substrates[ substrate ]
		@
		
	# Checks if this cell has a module
	#
	# @param [Module] module the module to check
	# @returns [Boolean] true if the module is included
	#
	has: ( module ) ->
		# TODO: ? check module type instead of object ref
		@_modules.indexOf( module ) isnt -1
	
	# Returns the amount of substrate in this cell
	# @param string substrate substrate to check
	# @returns int amount of substrate
	amount_of: ( substrate ) ->
		@_substrates[ substrate ]
	
		
	# Runs this cell
	#
	# @param [Integer] dt the step size
	# @param [Integer] timespan the time it should run for
	# @param [Function] callback optional callback
	# @returns [self] chainable instance
	#
	run : ( dt, timespan, callback ) ->
		# TODO: where to output
		t = 0
		while t <= timespan - dt
			t += dt
			
			callback { time: t, delta: dt, cell: @  } if callback?
		@
			
	
	# The properties
	Object.defineProperties @prototype,
		creation: 
			get : -> @_creation
		

# Makes this available globally. Use require later, but this will work for now.
(exports ? this).Cell = Cell