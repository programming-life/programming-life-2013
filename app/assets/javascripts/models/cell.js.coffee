class Cell

	# The constructor for the cell
	#
	constructor: ( ) ->
		@_creation = Date.now()
		@_modules = []
		@_substances = {}
	
	# Add module to cell
	#
	# @param [Module] module module to add to this cell
	# @returns [self] chainable instance
	#
	add: ( module ) ->
		@_modules.push module
		@
		
	# Add substance to cell
	#
	# @param [String] substance substance to add
	# @param [Integer] amount amount of substance to add
	# @returns [self] chainable instance
	#
	add_substance: ( substance, amount ) ->
		@_substances[ substance ] = amount
		@
		
	# Remove module from cell
	#
	# @param [Module] module module to remove from this cell
	# @returns [self] chainable instance
	#
	remove: ( module ) ->
		@_modules.splice( @_modules.indexOf module, 1 ) #TODO: update to use underscore without
		@
		
	# Removes this substance from cell
	#
	# @param [String] substance substance to remove from this cell
	# @returns [self] chainable instance
	#
	remove_substance: ( substance ) ->
		delete @_substances[ substance ]
		@
		
	# Checks if this cell has a module
	#
	# @param [Module] module the module to check
	# @returns [Boolean] true if the module is included
	#
	has: ( module ) ->
		# TODO: ? check module type instead of object ref
		@_modules.indexOf( module ) isnt -1
	
	# Returns the amount of substance in this cell
	# @param string substance substance to check
	# @returns int amount of substance
	amount_of: ( substance ) ->
		@_substances[ substance ]
	
	# Step runs this cell
	#
	# @param [Integer] dt the step time it should take
	# @returns [self] chainable instance
	#
	step : ( dt ) ->
		substances_diff = {};
		for module in @_modules
			# Each module should iterate with beforeStep values of all the substances
			substances_clone = {};
			for substance of @_substances 
				substances_clone[substance] = @_substances[substance]
			# Step this module with these values
			module_substances = module.step( dt, substances_clone )
			# Save the delta results
			for substance of module_substances
				substances_diff[substance] = module_substances[substance] - @_substances[substance]
		for substance of substances_diff
			@_substances[substance] += substances_diff[substance]
		@
	
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
			@step dt
			callback { time: t, delta: dt, cell: @  } if callback?
		@
			
	
	# The properties
	Object.defineProperties @prototype,
		creation: 
			get : -> @_creation
		

# Makes this available globally. Use require later, but this will work for now.
(exports ? this).Cell = Cell
