class Model.CellGrowth extends Model.Module
	constructor : ( params = { }, start = 1 ) ->	

		step = ( t, substrates ) -> 
			
			results = {}
				
			# Gracefull fallback if props are not apparent
			if ( @_test( substrates, @name ) )
				if ( @_test( substrates, @consume ) or @_test( substrates, @lipid ) or @_test( substrates, @protein ) )
					consume = substrates[@consume] ? 1
					lipid = substrates[@lipid] ? 1
					protein = substrates[@protein] ? 1
					mu = consume * lipid * protein * substrates[@name]
				
				if ( mu? )
					results[@name] = mu * substrates[@name]
					results[@consume] = -mu * substrates[@consume]
					
					#if ( @_test( substrates, @lipid ) )
					#	results[@lipid] = -mu * substrates[@lipid]
					#if ( @_test( substrates, @protein ) )
					#	results[@protein] = -mu * substrates[@protein]
					#if ( @_test( substrates, @metabolism ) )
					#	results[@metabolism] = -mu * substrates[@metabolism]
						
					#for transporter in @transporters
					#	if ( @_test( substrates, transporter ) )
					#		results[transporter] = -mu * substrates[transporter]
				
			return results
		
		defaults = { 
		
			consume: "s_int"
			lipid: "lipid"
			protein: "protein"
			name: "cell"
			
			#metabolism: "enzym"
			#transporters: [ "transporter_s_in", "transporter_p_out" ]
		}
		
		params = _( defaults ).extend( params )
				
		starts = {}
		starts[params.name] = start
		super params, step, starts

# Makes this available globally.
(exports ? this).Model.CellGrowth = Model.CellGrowth

			