class Lipid extends Module

	# Constructor for lipids
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of lipid
	# @param food [String] the substrate converted to lipid
	# @option k [Integer] the subscription rate, defaults to 1
	# @option dna [String] the dna to use, defaults to "dna"
	# @option substrate [String] the food, overides the food parameter, defaults to "s_int"
	#
	constructor: ( params = {}, start = 0, food = "s_int" ) ->
	
		# Step function for lipids
		step = ( t, substrates ) ->
		
			results = {}
			
			# Only calculate vlipid if the components are available
			if ( @test( substrates, @dna, @substrate ) )
				vlipid = @k * substrates[@dna] * substrates[@substrate]
			
			if ( vlipid )
				results["lipid"] = vlipid # todo mu
				results[@substrate] = -vlipid	
			
			return results
		
		# Default parameters set here
		defaults = { 
			k : 1
			dna : 'dna'
			substrate: food
		}
		
		params = _( defaults ).extend( params )
		super params, step, { 'lipid' : start }

(exports ? this).Lipid = Lipid