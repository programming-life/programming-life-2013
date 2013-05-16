# Simulates cell metabolism. Converts substrate into product.
#
# Parameters
# --------------------------------------------------------
#
# - k
#    - Synthesize rate
# - k_d
#    - Protein degradation
# - k_m
#    - MM kinetics constante
# - v
#    - v max for metabolism
# - consume
#    - All the metabolites required for Enzyme creation
# - orig
#	 - The metabolite before metabolism
# - dest
#    - The metabolite after metabolism
# 
# Properties
# --------------------------------------------------------
# 
# - vEnzymeSynth
#    - k * this 
# - degradation
#    - k_d * this
# - dilution
#    - mu * this
# - vMetabolism
#    - v * this * ( orig / ( orig + k_m ) )
#
# Equations
# --------------------------------------------------------
# 
# - this / dt
#    - vEnzymeSynth - dilution - degradation
# - consume / dt
#    - vEnzymeSynth
# - orig / dt
#    - -vMetabolism
# - dest / dt
#    - vMetabolism
#
class Model.Metabolism extends Model.Module

	# Constructor for Metabolism
	#
	# @param params [Object] parameters for this module
	# @param orig [String] the substrate to be converted
	# @param dest [String] the product after conversion
	# @param start [Integer] the initial value of metabolism, defaults to 0
	# @param name [String] the name of the metabolism, defaults to "enzyme"
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [Integer] k_met the conversion rate, defaults to 1
	# @option params [Integer] k_d the degredation rate, defaults to 1
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [String] orig the substrate to be converted, overrides substrate
	# @option params [String] dest the product after conversion, overrides product
	# @option params [String] name the name of the metabolism, overrides name
	#
	constructor: ( params = {}, start = 0, orig = "s#int", dest = "p#int", name = "enzyme" ) ->
	
		# Define differential equations here
		step = ( t, compounds, mu ) ->
		
			results = {}
			
			# Only if the components are available 
			if ( @_test( compounds, @name, @dna ) )
			
				# Rate of synthesization 
				# - The DNA constant k_dna called k
				# - The DNA itself called dna
				venzymesynth = @k * compounds[ @dna ]
				
				# Rate of dilution because of cell division
				# 
				dilution = mu * compounds[ @name ]
				
				# Rate of degradation
				# 
				degradation = @k_d * compounds[ @name ]
				
			# Only if the components are available 
			if ( @_test( compounds, @name, @orig, @dest ) )
				
				# Rate of Metabolism 
				# - The max speed constant v_max called v 
				# - The Enzyme itself
				# - The Compound to convert
				# - The Mihaelis-Mentin kinetics with constant k_m
				#
				vmetabolism = @v * compounds[ @name ]
				for orig in @orig
					vmetabolism *= ( compounds[ orig ] / ( compounds[ orig ] + @k_m ) )
				vmetabolism = 0 if ( isNaN vmetabolism )
				
			# If all components are available
			if venzymesynth?
			
				# The Enzyme increase is the rate minus dilution and degradation
				#
				results[ @name ] = venzymesynth - degradation - dilution
				
			# If all components are available
			if vmetabolism?
				
				for orig in @orig
					results[ orig ] = -vmetabolism
					
				for dest in @dest
					results[ dest ] = vmetabolism
			
			return results
		
		defaults = @_getParameterDefaults( start, orig, dest, name )
		params = _( params  ).defaults( defaults )
		meta_data = @_getParameterMetaData()
		
		super params, step, meta_data
		
	# Get parameter defaults array
	#
	# @param start [Integer] the start value
	# @return [Object] default values
	#
	_getParameterDefaults: ( start, orig, dest, name ) ->
		return { 
		
			# Parameters
			k: 1
			k_m: 1 
			v: 1
			k_d : 1
			orig: if _( orig ).isArray() then orig else [ orig ] 
			dest: if _( dest ).isArray() then dest else [ dest ] 
			
			# Meta-Parameters
			dna: "dna"
			
			# The name
			name: name
			
			# Start Values
			starts: { name : start, dest: 0 }
		}
		
	# Get parameter metadata
	#
	# @return [Object] metadata values
	#
	_getParameterMetaData: () ->
		return {
			properties:
				metabolites: [ 'orig', 'dest' ]
				parameters: [ 'k', 'k_m', 'v', 'k_d' ]
		}

(exports ? this).Model.Metabolism = Model.Metabolism