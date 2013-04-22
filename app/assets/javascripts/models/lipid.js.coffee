class Lipid extends Module

	constructor: ( params = {}, food = "s_int" ) ->
	
		# Step function for lipids
		step = ( t, substrates ) ->
		
			results = {}
			if ( @test( @dna, @substrate ) )
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
		super params, step

(exports ? this).Lipid = Lipid