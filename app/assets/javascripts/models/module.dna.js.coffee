class Model.DNA extends Model.Module

	# Constructor for DNA
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of dna
	# @param prefix [String] the prefix name to use
	# @param food [String] the substrate converted to dna
	# @option params [Integer] k the synth rate, defaults to 1
	# @option params [String] name the name to use, defaults to prefix_dna or dna if prefix is undefined
	# @option params [String] consume the food, overides the food parameter, defaults to "s_int"
	#
	constructor: ( params = {}, start = 1, prefix, food = "p_int" ) ->
			
		# Step function for lipids
		step = ( t, substrates, mu ) ->
		
			results = {}
						
			# Only calculate vlipid if the components are available
			if ( @_test( substrates, @name, @consume ) )
				vdnasynth = @k * substrates[@name] * substrates[@consume]
				growth = mu * substrates[@name]
				
			if ( vdnasynth? and vdnasynth > 0 )
				results[@name] = vdnasynth * growth
				results[@consume] = -vdnasynth	
			
			return results
		
		# Default parameters set here
		defaults = { 
			k : 1
			name : if prefix then "#{prefix}_dna" else "dna"
			consume: food
			starts: { name : start }
		}
		
		params = _( defaults ).extend( params )
		super params, step

(exports ? this).Model.DNA = Model.DNA