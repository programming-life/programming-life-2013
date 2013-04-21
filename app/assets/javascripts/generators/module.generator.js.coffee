class ModuleGenerator
	
	# Creates a infrastructure
	#
	# @param [String] name the dna name
	# @param [Object] params the options
	# @returns [Array] the modules
	#
	infrastructure : ( params = {}, lipid_food = "s_in", protein_food = "p_in", own_dna = false ) -> 
		results = []
		
		if ( !own_dna )
			results = results.concat @dna( false, params )
			
		results = results.concat(
			@lipid( params, lipid_food, own_dna )
			@protein( params, protein_food, own_dna )
		)
			
		return results
		
	# Creates a DNA module
	#
	# @param [String] name the dna name
	# @param [Object] params the options
	# @returns [Array] the modules
	#
	dna : ( name, params = {} ) ->
		return [ 
			new Module(
				{ 
					k : params.k_dna ? 1
					name: if name then name + "_dna" else "dna"
				}, 
				( t, substrates ) ->
					results = {}
					results[this.name] = this.k * substrates[this.name] * 1 
					return results
			)
		]
		
	# Creates Lipid modules
	#
	# @param [Object] params the options
	# @param [Boolean] own_dna creates own dna for module
	# @returns [Array] the modules
	#
	lipid : ( params = {}, food = "s_in", own_dna = false ) ->
		modules = []
		dna = "dna"
		
		if ( own_dna )
			modules = modules.concat @dna( 'lipid', params )
			dna = "lipid_dna"
		
		modules.push new Module( 
			{ 
				k: params.k_l ? 1 
				dna: dna
				substrate: food
			},
			( t, substrates ) ->
				vlipid = this.k * substrates[this.dna] * substrates[this.substrate]
				
				results = {}
				results["lipid"] = vlipid # todo mu
				results[this.substrate] = -vlipid	
				
				return results
		)
		
		return modules
		
	# Creates Transporter into the cell
	#
	# @param [Object] params the options
	# @param [String] substrate the substrate name
	# @param [Boolean] own_dna creates own dna for module
	# @returns [Array] the modules
	#
	transporter_in : ( params = {}, substrate = "s", own_dna = false ) ->
		return @transporter( params, "#{substrate}_ext", "#{substrate}_in", own_dna )
		
	# Creates Transporter out of the cell
	#
	# @param [Object] params the options
	# @param [String] product the product name
	# @param [Boolean] own_dna creates own dna for module
	# @returns [Array] the modules
	#
	transporter_out : ( params = {}, product = "p", own_dna = false ) ->
		return @transporter( params, "#{product}_in", "#{product}_ext", own_dna )
		
	# Creates Transporter
	#
	# @param [Object] params the options
	# @param [String] origin the origin name
	# @param [String] destination the destination name
	# @param [Boolean] own_dna creates own dna for module
	# @returns [Array] the modules
	#
	transporter : ( params = {}, origin, destination, own_dna = false ) ->
		modules = []
		dna = "dna"
		
		if ( own_dna )
			modules = modules.concat @dna( 'transporter', params )
			dna = "transporter_dna"
			
		modules.push new Module( 
			{ 
				k: params.k_tr ? 1
				v_max : params.v_max ? 1 
				k_rate: params.k_rate ? 1
				orig: origin
				dest: destination
				dna: dna
			},
			( t, substrates ) -> 
				vtransport = this.v_max * substrates.transporter * 
					( substrates[this.orig] / substrates[this.orig] + this.k_rate )
				results = {}
				results["transporter"] = this.k * substrates[this.dna]
				results[this.dest] = vtransport
				results[this.orig] = -vtransport
				return results
		)
		
		return modules
		
	# Creates Metabolism
	#
	# @param [Object] params the options
	# @param [String] substrate the substrate name
	# @param [String] product the product name
	# @param [Boolean] own_dna creates own dna for module
	# @returns [Array] the modules
	#
	metabolism : ( params = {}, substrate, product, own_dna = false ) ->
		modules = []
		dna = "dna"
		
		if ( own_dna )
			modules = modules.concat @dna( 'metabolism', params )
			dna = "metabolism_dna"
			
		modules.push new Module(
			{ 
				k: params.k_ei ? 1
				k_met: params.k_met ? 1 
				v_max: params.v_max ? 1
				substrate: substrate ? "s_in"
				product: product ? "p_in"
				dna: dna
			},
			( t, substrates ) -> 
				vmetabolism = this.v_max * substrates.enzym * 
					( substrates[this.substrate] / substrates[this.substrate] + this.k_met )
				result = {}
				result["enzym"] = this.k * substrates[this.dna]
				result[this.substrate] = -vmetabolism
				result[this.product] = vmetabolism
				return result
		)
		
		return modules
		
    # Creates Protein
	#
	# @param [Object] params the options
	# @param [Boolean] own_dna creates own dna for module
	# @returns [Array] the modules
	#		
	protein : ( params = {}, food = "p_in", own_dna = false ) ->
		modules = []
		dna = "dna"
		
		if ( own_dna )
			modules = modules.concat @dna( 'protein', params )
			dna = "protein_dna"
		
		modules.push new Module( 
			{ 
				k: params.k_p ? 1
				dna: dna
				product: food
			},
			( t, substrates ) -> 
				
				vprotsynth = this.k * this.subtrates[this.dna] * this.substrates[this.product];
				result = {}
				result["protein"] = vprotsynth
				result[this.product] = -vprotsynth
				return result
		)
		
		return modules
		
(exports ? this).ModuleGenerator = new ModuleGenerator