# Simulates protein synthesization.
#
# Parameters
# --------------------------------------------------------
# 
# - k
#    - Synthesize rate
# - k_d
#    - Protein degradation
# - consume
#    - All the metabolites required for Protein creation
# 
# Properties
# --------------------------------------------------------
# 
# - vProteinSynth
#    - k * this * consume
# - degradation
#    - k_d * this
# - dilution
#    - mu * this
#
# Equations
# --------------------------------------------------------
# 
# - this / dt
#    - vProteinSynth - dilution - degradation
# - consume / dt
#    - vProteinSynth
#
class Model.Protein extends Model.Module

	# Constructor for Protein
	#
	# @param params [Object] parameters for this module
	# @param consume [String, Array<String>] the metabolite to be converted
	# @param product [String] the product after conversion
	# @param start [Integer] the initial value of metabolism, defaults to 0
	# @param name [String] the name of the metabolism, defaults to "enzym"
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [Integer] k_d the degration rate, defaults to 1
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [Array<String>] consume the metabolite to convert, overrides consume
	# @option params [String] name the name of the protein, overrides name
	#
	constructor: ( params = {}, start = 0, consume = "p#int", name = "protein" ) ->			
		
		# Define differential equations here
		step = ( t, compounds, mu ) ->
		
			results = {}
			
			# Only if the components are available 
			if ( @_test( compounds, @dna, @consume, @name  ) )
				
				# Rate of synthesization 
				# - The DNA constant k_dna called k
				# - The DNA itself called dna
				# - The required metabolites 
				#
				vproteinsynth = @k * compounds[ @dna ]
				for c in @consume
					vproteinsynth *= compounds[ c ]
					
				# Rate of dilution because of cell division
				# 
				dilution = mu * compounds[ @name ]
				
				# Rate of degradation 
				# 
				degradation  = @k_d * compounds[ @name ]
			
			# If all components are available
			if vproteinsynth?
			
				# The Protein increase is the rate minus dilution and degradation 
				#
				results[ @name ] = vproteinsynth - degradation  - dilution
				
				# All the metabolites required for synthesisation
				# are hereby subtracted by the increase in Protein
				#
				for c in @consume
					results[ c ] = - vproteinsynth
					
			return results
		
		# Default parameters set here
		defaults = @_getParameterDefaults( start, name, consume )
		params = _( defaults ).extend( params )
		meta_data = @_getParameterMetaData()
		
		super params, step, meta_data
		
	# Get parameter defaults array
	#
	# @param start [Integer] the start value
	# @return [Object] default values
	#
	_getParameterDefaults: ( start, name, consume ) ->
		return { 
		
			# Parameters
			k : 1
			k_d : 1
			consume: if _( consume ).isArray() then consume else [ consume ]
			
			# Meta-parameters
			dna: "dna"
			
			# The name 
			name : name
			
			# The start values
			starts: { name : start }
		}
		
	# Get parameter metadata
	#
	# @return [Object] metadata values
	#
	_getParameterMetaData: () ->
		return {
			properties:
				parameters: [ 'k', 'k_d' ]
				metabolites: [ 'consume' ]
		}

(exports ? this).Model.Protein = Model.Protein