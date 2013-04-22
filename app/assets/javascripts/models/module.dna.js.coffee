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
			
			if ( @_test( substrates, @grow.consume ) or @_test( substrates, @grow.lipid ) or @_test( substrates, @grow.protein ) or @_test( substrates, @grow.metabolism ) )
					
				consume = substrates[@grow.consume] ? 1
				lipid = substrates[@grow.lipid] ? 1
				protein = substrates[@grow.protein] ? 1
				mu = consume * lipid * protein * substrates[@grow.cell]
			
			# Only calculate vlipid if the components are available
			if ( mu? and @_test( substrates, @name, @consume ) )
				vdnasynth = @k * substrates[@name] * substrates[@consume] * mu
			
			if ( vdnasynth? and vdnasynth > 0 )
				results[@name] = vdnasynth 
				results[@consume] = -vdnasynth	
			
			return results
		
		# Default parameters set here
		defaults = { 
			k : 1
			name : if prefix then "#{prefix}_dna" else "dna"
			consume: food
			grow : 
				cell : "cell"
				lipid : "lipid"
				consume : "s_int"
				protein : "protein"
				metabolism : "enzym"
		}
		
		params = _( defaults ).extend( params )
		
		starts = {};
		starts[params.name] = start
		super params, step, starts

(exports ? this).Model.DNA = Model.DNA