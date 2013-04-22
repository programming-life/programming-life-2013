class Model.Protein extends Model.Module

	# Constructor for Protein
	#
	# @param params [Object] parameters for this module
	# @param substrate [String] the substrate to be converted
	# @param product [String] the product after conversion
	# @param start [Integer] the initial value of metabolism, defaults to 0
	# @param name [String] the name of the metabolism, defaults to "enzym"
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [Integer] k_d the degration rate, defaults to 1
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [String] substrate the substrate to convert, overrides food
	# @option params [String] name the name of the protein, overrides name
	#
	constructor: ( params = {}, start = 0, food = "p_int", name = "protein" ) ->			
		# Step function for lipids
		step = ( t, substrates, mu ) ->
		
			results = {}
			if ( @_test( substrates, @dna, @substrate ) )
				vprotsynth = @k * substrates[@dna] * substrates[@substrate]
				degrade = @k_d * ( substrates[@name] ? 0 )
				growth = mu * ( substrates[@name] ? 0 )
			
			if ( vprotsynth? and vprotsynth > 0 )
				results[@name] = vprotsynth - growth - degrade
				results[@substrate] = -vprotsynth
				
			return results
		
		# Default parameters set here
		defaults = { 
			k : 1
			k_d : 1
			dna: "dna"
			substrate: food
			name : name
		}
		
		params = _( defaults ).extend( params )
		
		starts = {}
		starts[params.name] = start
		super params, step, starts

(exports ? this).Model.Protein = Model.Protein