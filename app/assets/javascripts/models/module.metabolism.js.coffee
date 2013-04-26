class Model.Metabolism extends Model.Module

	# Constructor for Metabolism
	#
	# @param params [Object] parameters for this module
	# @param substrate [String] the substrate to be converted
	# @param product [String] the product after conversion
	# @param start [Integer] the initial value of metabolism, defaults to 0
	# @param name [String] the name of the metabolism, defaults to "enzym"
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [Integer] k_met the conversion rate, defaults to 1
	# @option params [Integer] k_d the degredation rate, defaults to 1
	# @option params [Integer] v the speed scaler (vmax), defaults to 1
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [String] orig the substrate to be converted, overrides substrate
	# @option params [String] dest the product after conversion, overrides product
	# @option params [String] name the name of the metabolism, overrides name
	#
	constructor: ( params = {}, start = 0, substrate = "s_int", product = "p_int", name = "enzym" ) ->
	
		# Step function for lipids
		step = ( t, substrates, mu ) ->
		
			results = {}
			
			if ( @_test( substrates, @name, @orig ) )
				vmetabolism = @v * substrates[@name] * ( substrates[@orig] / ( substrates[@orig] + @k_m ) )

			if ( @_test( substrates, @dna ) )
				current = ( substrates[@name] ? 0 )
				growth = mu * current
				results[@name] = @k * substrates[@dna] - @k_d * current - growth
				
			if ( vmetabolism? and vmetabolism > 0 )
				results[@orig] = -vmetabolism
				results[@dest] = vmetabolism
					
			return results
		
		# Default parameters set here
		defaults = { 
			k: 1
			k_m: 1 
			k_d : 1
			v: 1
			orig: substrate
			dest: product
			dna: "dna"
			name: name
			starts: { name : start, dest: 0 }
		}
		
		params = _( defaults ).extend( params )
		super params, step

(exports ? this).Model.Metabolism = Model.Metabolism