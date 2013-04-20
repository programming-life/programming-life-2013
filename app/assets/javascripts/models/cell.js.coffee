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
	# @param [Integer] timespan the time it should run for
	# @returns [self] chainable instance
	#
	run : ( timespan ) ->
		
		variables = [ ]
		values = [ ]
						
		# We would like to get all the variables in all the equations, so
		# that's what we are going to do. Then we can insert the value indices
		# into the equations.
		for substrate, value of @_substrates
			variables.push substrate
			values.push value
	
		# Create the mapping from variable to value index
		mapping = { }
		for i, variable of variables
			mapping[variable] = parseInt i
			
		map = ( values ) => 
			variables = { }
			for variable, i of mapping
				variables[ variable ] = values[ i ]
			variables
			
		# The step function for this module
		#
		# @param [Integer] t the current time
		# @param [Array] v the current value array
		# @returns [Array] the delta values
		step = ( t, v ) =>
		
			results = [ ]
			variables = [ ]
			
			# All dt are 0, so that when a variable was NOT processed, the
			# value remains the same
			for variable, index of mapping
				results[ index ] = 0
				
			# Get those substrates named
			mapped = map v
				
			# Run all the equations
			for module in @_modules
				module_results = module.step( t, mapped )
				for variable, result of module_results
					current = results[ mapping[ variable ] ] ? 0
					results[ mapping[ variable ] ] = current + result
								
			results
			
		# Run the ODE from 0...timespan with starting values and step function
		sol = numeric.dopri( 0, timespan, values, step )
		
		# Return the system results
		sol
	
	# The properties
	Object.defineProperties @prototype,
		creation: 
			get : -> @_creation
		

# Makes this available globally. Use require later, but this will work for now.
(exports ? this).Cell = Cell
