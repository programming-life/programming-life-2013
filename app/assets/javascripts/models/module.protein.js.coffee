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
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [Integer] k_d the degration rate, defaults to 1
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [Array<String>] consume the metabolite to convert, overrides consume
	# @option params [String] name the name of the protein, overrides name
	#
	constructor: ( params = {} ) ->			
		
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
		defaults = Protein.getParameterDefaults()
		params = _( defaults ).extend( params )
		metadata = Protein.getParameterMetaData()
		
		super params, step, metadata
		
	# Get parameter defaults array
	#
	# @return [Object] default values
	#
	@getParameterDefaults: () ->
		return { 
		
			# Parameters
			k : 1
			k_d : 1
			consume: [ "p#int" ]
			
			# Meta-parameters
			dna: "dna"
			
			# The name 
			name : "complex"
			
			# The start values
			starts: { name : 0 }
		}
		
	# Get parameter metadata
	#
	# @return [Object] metadata values
	#
	@getParameterMetaData: () ->
		return {
		
			properties:
				parameters: [ 'k', 'k_d' ]
				metabolites: [ 'consume' ]
				dna: [ 'dna' ]
				
			tests:
				compounds: [ 'dna', 'consume', 'name' ]
		}