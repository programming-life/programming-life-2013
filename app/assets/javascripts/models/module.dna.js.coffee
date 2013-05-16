# Simulates DNA existance and synthesis in the Cell
#
# Parameters
# --------------------------------------------------------
#
# - k
#    - Synthesize rate
# - consume
#    - All the metabolites required for DNA creation
# 
# Properties
# --------------------------------------------------------
# 
# - vDNASynth
#    - k * this * consume
# - dilution
#    - mu * this
#
# Equations
# --------------------------------------------------------
# 
# - this / dt
#    - vDNASynth - dilution
# - consume / dt
#    - vDNASynth
#
class Model.DNA extends Model.Module

	# Constructor for DNA
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of dna
	# @param prefix [String] the prefix name to use
	# @param consume [String] the metabolite converted to dna
	# @option params [Integer] k the synth rate, defaults to 1
	# @option params [String] name the name to use, defaults to prefix_dna or dna if prefix is undefined
	# @option params [String] consume the food, overides the consume parameter, defaults to "p#int"
	#
	constructor: ( params = {}, start = 1, prefix, consume = "p#int" ) ->
			
		# Define differential equations here
		step = ( t, compounds, mu ) ->
		
			results = {}
						
			# Only if the components are available
			if ( @_test( compounds, @name, @consume ) )
				
				# Rate of synthesization 
				# - The DNA constant k_dna called k
				# - The DNA itself ( name refers to the dna id )
				# - The required metabolites 
				#
				vdnasynth = @k * compounds[ @name ]
				for c in @consume
					vdnasynth *= compounds[ c ]
					
				# Rate of dilution because of cell division
				# 
				dilution = mu * compounds[ @name ]
				
			# If all components are available 
			if vdnasynth? 
				
				# The DNA increase is the rate minus dilution
				#
				results[ @name ] = vdnasynth - dilution
				
				# All the metabolites required for synthesisation
				# are hereby subtracted by the increase in DNA
				#
				for c in @consume
					results[ c ] = -vdnasynth	
			
			return results
		
		# Define default parameters here
		defaults = @_getParameterDefaults( start, prefix, consume )
		params = _( params ).defaults( defaults )
		meta_data =  @_getParameterMetaData()
		
		super params, step, meta_data
		
	# Get parameter defaults array
	#
	# @param start [Integer] the start value
	# @return [Object] default values
	#
	_getParameterDefaults: ( start, prefix, consume ) ->
		return { 
		
			# Parameters
			k : 1
			consume: if _( consume ).isArray() then consume else [ consume ]

			# Start value
			starts: { name : start }
			
			# Display name
			name : if prefix then "#{prefix}_dna" else "dna"
		}
		
	# Get parameter metadata
	#
	# @return [Object] metadata values
	#
	_getParameterMetaData: () ->
		return {
			properties:
				metabolites: [ 'consume' ]
				parameters: [ 'k' ]
		}

(exports ? this).Model.DNA = Model.DNA