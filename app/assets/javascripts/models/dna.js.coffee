class DNA extends Module

	constructor: ( params = {}, name = "dna", food = "p_int" ) ->
	
		# Step function for lipids
		step = ( t, substrates ) ->
		
			results = {}			
			return results
		
		# Default parameters set here
		defaults = { 
		}
		
		params = _( defaults ).extend( params )
		super params, step

(exports ? this).DNA = DNA