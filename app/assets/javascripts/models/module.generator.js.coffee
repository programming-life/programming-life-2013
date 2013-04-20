class ModuleGenerator
	infrastructure : ( params ) -> 
		[ @lipid params, 
		
		]
		
	dna : ( name, params ) ->
		[ new Module(
			{ k : params.kdna ? 1 }
			( t, substrates ) ->
				{ "{name}_dna" : this.k * substrates["{name}_dna"] * 1 } # Prod
		]
		
	lipid : ( params ) ->
		lipid_dna = @dna( 'lipid', params )
		lipid = new Module(
			{ k: params.kl ? 1 },
			( t, substrates ) ->
				{ "lipid": this.k * substrates.lipid_dna * substrates.s_in } #- mu
		)
		[ lipid_dna, lipid ]