# Simulates Cell Growth / Population size
#
# Parameters
# --------------------------------------------------------
# 
# - infrastructure
#    - Infrastructure for population growth
# - metabolites
#    - All the metabolites required for population growth
# 
# Properties
# --------------------------------------------------------
#
# - mu
#    - infrastructure * metabolites
#
# Equations
# --------------------------------------------------------
#
# - this / dt
#    - mu * this
#
class Model.CellGrowth extends Model.Module

	# Constructor for Cell Growth
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of metabolism, defaults to 0
	# @option params [Array<String>] metabolites the metabolites to use for cell growth
	# @option params [Array<String>] infrastructure the compounds to use for cell growth
	# @option params [String] name the name of the cell
	#
	constructor : ( params = { }, start = 1 ) ->	

		# Define differential equations here
		step = ( t, compounds, mu ) -> 
			
			results = {}

			if ( @_test( compounds, @name ) )
				# The Population size
				# - growth rate
				# - population
				#
				results[ @name ] = mu * compounds[ @name ]
				
			return results
				
		defaults = @_getParameterDefaults( start )
		params = _( params ).defaults( defaults )
		metadata =  @_getParameterMetaData()
		
		super params, step, metadata
		
	# Add the mu getter for this module
	#
	# @param step [Function] the step function
	#
	_defineGetters: ( step, metadata ) ->
	
		cell_growth = @
		Object.defineProperty( @, 'mu',
			
			# @property [Function] the function to get the cell growth rate
			get: =>
			
				# This returns the cell growth, but according to this module,
				# meaning that this property can be used for all modules to
				# get a result in the context of cell growth
				return ( compounds ) =>
					
					# Only calculate if compounds are available
					if ( cell_growth._test( compounds, cell_growth.infrastructure, cell_growth.metabolites ) )
					
						# The growth rate is established as
						# - all the infrastructure:
						#	- lipid
						#	- protein
						#	- s#int
						result = 1
						for i in cell_growth.infrastructure
							result *= compounds[ i ]
						for m in cell_growth.metabolites
							result *= compounds[ m ]
						return result
						
					return 0
		)
		super step, metadata
		
	# Get parameter defaults array
	#
	# @param start [Integer] the start value
	# @return [Object] default values
	#
	_getParameterDefaults: ( start ) ->
		return { 
		
			# Parameters
			metabolites: [ "s#int" ]
			infrastructure : [ "lipid", "protein" ]
			
			# Name of the population compound
			name: "cell"
			
			# Start values
			starts : { name : start }
		}
		
	# Get parameter metadata
	#
	# @return [Object] metadata values
	#
	_getParameterMetaData: () ->
		return {
			properties:
				metabolites: [ 'metabolites' ]
				compounds: [ 'infrastructure' ]
		}

# Makes this available globally.
(exports ? this).Model.CellGrowth = Model.CellGrowth

			