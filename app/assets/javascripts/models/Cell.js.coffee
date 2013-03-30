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
	run : ( dt, timespan ) ->
		# TODO: where to output
		values = [ 1, 0, 0, 10, 0 ]
		
		kDNA = 1
		Sint = 1
		Lipid = 1
		
		module = ( v ) ->
			a = 0
			b = 1
			kDNA * v[ a ] * 1 * Sint * Lipid * 1 * v[ b ] 
			
		# equations = ( t, v ) -> { DNA : ( kDNA * t.DNA * 1 ) * ( Sint * Lipid * 1 ) * t.DNA }
		equations = ( t, v ) -> 
		
			DNA = v[0];
			Lipid = v[1];
			Prod = v[2];
			Protein = v[3];
			Sint = v[4];
		
			kDNA = 1
			kLipid = 1
			kProtein = 1

			vDNASynth = kDNA * DNA * Prod	
			vLipid = 0
			#vTransport = kTransport * Transporter * Sext / (Sext + kM )
			vTransport = 1
			mu = Sint * Lipid * Protein
			
			dDNA = vDNASynth * mu * DNA
			dLipid = kLipid * DNA * Sint - mu * Lipid
			dProd = 1
			dProtein = kProtein * DNA - mu * Protein
			dSint = vTransport - 0 - vLipid
			
			[ dDNA, dLipid, dProd, dProtein, dSint ]
			
		sol = numeric.dopri( 0, timespan / dt, values, equations )
		console.info( sol );
		sol
		
			
	
	# The properties
	Object.defineProperties @prototype,
		creation: 
			get : -> @_creation
		

# Makes this available globally. Use require later, but this will work for now.
(exports ? this).Cell = Cell