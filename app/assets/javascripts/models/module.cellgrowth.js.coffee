class Model.CellGrowth extends Model.Module

	# Constructor for Cell Growth
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of metabolism, defaults to 0
	# @option params [String] consume the substrate to use for cell growth
	# @option params [String] name the name of the cell
	#
	constructor : ( params = { }, start = 1 ) ->	

		step = ( t, substrates, mu ) -> 
			
			results = {}
			
			# Gracefull fallback if props are not apparent
			if ( @_test( substrates, @name ) )
				growth = mu( substrates ) * substrates[@name]
				
				if ( growth_rate? )
					results[@name] = growth
					#results[@consume] = -growth_rate * substrates[@consume] # TODO SHOULD THIS BE HERE???
				
			return results
		
		defaults = { 
			consume: "s_int"
			infrastructure : [ "lipid", "protein" ]
			name: "cell"
		}
		
		params = _( defaults ).extend( params )
				
		starts = {}
		starts[params.name] = start
				
		# I need this reference
		cell_growth = @
		
		Object.defineProperty( @, 'mu',
			get: =>
			
				# This returns the cell growth, but according to this module,
				# meaning that this property can be used for all modules to
				# get a result in the context of cell growth
				return ( substrates ) =>
					if ( _( cell_growth.infrastructure ).some( ( substrate ) -> cell_growth._test( substrates, substrate ) ) and cell_growth._test( substrates, cell_growth.name ) )
						base = substrates[cell_growth.name] * ( substrates[cell_growth.consume] ? 1 )
						for substrate in cell_growth.infrastructure
							base *= ( substrates[substrate] ? 1 )
						return base
					return 0
		)
		
		super params, step, starts		

# Makes this available globally.
(exports ? this).Model.CellGrowth = Model.CellGrowth

			