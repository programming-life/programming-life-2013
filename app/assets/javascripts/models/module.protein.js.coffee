class Model.Protein extends Model.Module

	# Constructor for Metabolism
	#
	# @param params [Object] parameters for this module
	# @param substrate [String] the substrate to be converted
	# @param product [String] the product after conversion
	# @param start [Integer] the initial value of metabolism, defaults to 0
	# @param name [String] the name of the metabolism, defaults to "enzym"
	# @option k [Integer] the subscription rate, defaults to 1
	# @option dna [String] the dna to use, defaults to "dna"
	# @option substrate [String] the substrate to be converted, overrides food
	# @option name [String] the name of the protein, overrides name
	#
	constructor: ( params = {}, food = "p_int", start = 0, name = "protein" ) ->			
	
		# Step function for lipids
		step = ( t, substrates ) ->
		
			results = {}
			if ( @_test( substrates, @dna, @substrate ) )
				vprotsynth = @k * substrates[@dna] * substrates[@substrate]
			
			if ( vprotsynth and vprotsynth > 0 )
				results[@name] = vprotsynth
				results[@substrate] = -vprotsynth
				
			return results
		
		# Default parameters set here
		defaults = { 
			k : 1
			dna: "dna"
			substrate: food
			name : name
		}
		
		params = _( defaults ).extend( params )
		
		starts = {}
		starts[params.name] = start
		super params, step, starts

(exports ? this).Model.Protein = Model.Protein