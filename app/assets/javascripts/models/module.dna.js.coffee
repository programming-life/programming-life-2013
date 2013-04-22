class Model.DNA extends Model.Module

	# Constructor for DNA
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of dna
	# @param prefix [String] the prefix name to use
	# @param food [String] the substrate converted to dna
	# @option k [Integer] the synth rate, defaults to 1
	# @option name [String] the name to use, defaults to prefix_dna or dna if prefix is undefined
	# @option consume [String] the food, overides the food parameter, defaults to "s_int"
	#
	constructor: ( params = {}, start = 1, prefix, food = "p_int" ) ->
			
		# Step function for lipids
		step = ( t, substrates ) ->
		
			results = {}
			
			# Only calculate vlipid if the components are available
			if ( @_test( substrates, @name, @consume ) )
				vdnasynth = @k * substrates[@name] * substrates[@consume]
			
			if ( vdnasynth? and vdnasynth > 0 )
				results[@name] = vdnasynth # todo mu
				results[@consume] = -vdnasynth	
			
			return results
		
		# Default parameters set here
		defaults = { 
			k : 1
			name : if prefix then "#{prefix}_dna" else "dna"
			consume: food
		}
		
		params = _( defaults ).extend( params )
		
		starts = {};
		starts[params.name] = start
		super params, step, starts

(exports ? this).Model.DNA = Model.DNA