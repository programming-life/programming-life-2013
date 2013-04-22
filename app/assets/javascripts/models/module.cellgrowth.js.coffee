class Model.CellGrowth extends Model.Module
	constructor : ( params = { }, start = 1 ) ->	

		step = ( t, substrates ) -> 
			
			results = {}
							
			# Gracefull fallback if props are not apparent
			if ( @_test( substrates, @consume ) or @_test( substrates, @lipid ) or @_test( substrates, @protein ) )
				consume = substrates[@consume] ? 1
				lipid = substrates[@lipid] ? 1
				protein = substrates[@lipid] ? 1
				mu = consume * lipid * protein
			
			if ( mu and @_test( substrates, @name ) )
				results[@name] = mu * substrates[@name]
				results[@consume] = -mu * substrates[@consume]
				
				if ( @_test( substrates, @lipid ) )
					results[@lipid] = -mu * substrates[@lipid]
				if ( @_test( substrates, @lipid ) )
					results[@protein] = -mu * substrates[@protein]
				
			return results
		
		defaults = { 
			consume: "p_int"
			lipid: "lipid"
			protein: "protein"
			name: "cell"
		}
		
		params = _( defaults ).extend( params )
				
		starts = {}
		starts[params.name] = start
		super params, step, starts

# Makes this available globally.
(exports ? this).Model.CellGrowth = Model.CellGrowth

			