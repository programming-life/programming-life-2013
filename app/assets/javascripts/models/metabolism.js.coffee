class Metabolism extends Module

	# Constructor for Metabolism
	#
	# @param params [Object] parameters for this module
	# @param substrate [String] the substrate to be converted
	# @param product [String] the product after conversion
	# @param start [Integer] the initial value of metabolism, defaults to 0
	# @param name [String] the name of the metabolism, defaults to "enzym"
	# @option k [Integer] the subscription rate, defaults to 1
	# @option k_tr [Integer] the conversion rate, defaults to 1
	# @option v [Integer] the speed scaler (vmax), defaults to 1
	# @option dna [String] the dna to use, defaults to "dna"
	# @option orig [String] the substrate to be converted, overrides substrate
	# @option dest [String] the product after conversion, overrides product
	# @option name [String] the name of the metabolism, overrides name
	#
	constructor: ( params = {}, substrate = "s_int", product = "p_int", start = 0, name = "enzym" ) ->
	
		# Step function for lipids
		step = ( t, substrates ) ->
			if ( @_test( substrates, @name, @orig ) )
				vmetabolism = @v * substrates[@name] * ( substrates[@orig] / ( substrates[@orig] + @k_met ) )

			results = {}
			if ( @_test( substrates, @dna ) )
				results[@name] = @k * substrates[@dna]
					
			if ( vmetabolism? and vmetabolism > 0 )
				results[@name] = -vmetabolism
				results[@orig] = vmetabolism
					
			return result
		
		# Default parameters set here
		defaults = { 
			k: 1
			k_met: 1 
			v: 1
			orig: substrate
			dest: product
			dna: "dna"
			name: name
		}
		
		params = _( defaults ).extend( params )
		
		starts = {};
		starts[params.name] = start
		super params, step, starts

(exports ? this).Metabolism = Metabolism