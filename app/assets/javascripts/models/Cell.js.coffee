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
		# 1: DNA
		# 2: Lipid
		# 3: Transporter
		# 4: Ei
		# 5: Protein
		# 6: Sint
		# 7: Sext
		# 8: Prod
		# 9: Cell
		values = [ 
			20, 
			1, 
			1, 
			1, 
			100, 
			1, 
			1000, 
			1, 
			1 
		]
			
		equations = ( t, v ) -> 
		
			DNA = v[0]
			Lipid = v[1]
			#Transporter = v[2]
			#Ei = v[3]
			#Protein = v[4]
			#Sint = v[5]
			#Sext = v[6]
			#Prod = v[7]
			#Cell = v[8]
		
			kDNA = 5
			kLipid = 5
			kProtein = 1
			kTransporter = 1
			kEi = 1
			kM = 1
			kD = 1

			vMax = 1
			vLipid = 1
			
			# Speed of DNA synthesize
			vDNASynth = kDNA * DNA * 1 #prod	
			
			#vProtSynth = kProtein * DNA * Prod
			#vTransportIn = kTransporter * Transporter * ( Sext / ( Sext + kM ) )
			#vTransportOut = kTransporter * Transporter * Prod
			#vEi = vMax * Ei * ( Sint / ( Sint + kM ) )
			mu = 1 * Lipid * 1 #Sint * Lipid * Protein
			
			dDNA = vDNASynth * mu * DNA
			
			dLipid = kLipid * DNA * 1 - mu * Lipid #sint
			dTransporter = 0 #kTransporter * DNA * Sint - mu * Transporter
			dEi = 0 #kEi * DNA - mu * Ei - kD * Ei
			dProtein = 0 #kProtein * DNA - mu * Protein - 0 # Kpd * P 
			dSint = 0 #vTransportIn - vEi - vLipid
			dSext = 0 #Sext - vTransportIn * Cell
			dProd = 0 #vEi - vTransportOut - vDNASynth - vProtSynth
			dCell = 0 #DNA * Lipid * Protein * Cell
			
			[ dDNA ,dLipid ] #, dTransporter, dEi, dProtein, dSint, dSext, dProd, dCell ]
			
		sol = numeric.dopri( 0, timespan / dt, values, equations )
		console.info( sol );
		sol
		
			
	
	# The properties
	Object.defineProperties @prototype,
		creation: 
			get : -> @_creation
		

# Makes this available globally. Use require later, but this will work for now.
(exports ? this).Cell = Cell