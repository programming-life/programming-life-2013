# Simulates a cell border from lipids
#
class Model.Lipid extends Model.Module

	# Constructor for lipids
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of lipid, defaults to 1
	# @param food [String] the substrate converted to lipid, defaults to "s_int"
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [String] consume the consume substrate, overides the food parameter, defaults to "s_int"
	# @option params [String] name the name, defaults to "lipid"
	#
	constructor: ( params = {}, start = 1, food = "s_int" ) ->
	
		# Step function for lipids
		step = ( t, substrates, mu ) ->
		
			results = {}
			
			# Only calculate vlipid if the components are available
			if ( @_test( substrates, @dna, @consume ) )
				vlipid = @k * substrates[@dna] * substrates[@consume]
				growth = mu * ( substrates[@name] ? 0 )
			
			if ( vlipid? and vlipid > 0 )
				results[@name] = vlipid - growth
				results[@consume] = -vlipid	
			
			return results
		
		# Default parameters set here
		defaults = { 
			k : 1
			dna : 'dna'
			consume: food
			name : "lipid"
			starts: { name : start }
		}
		
		params = _( defaults ).extend( params )
		super params, step

(exports ? this).Model.Lipid = Model.Lipid