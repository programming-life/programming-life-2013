# Simulates cell metabolism. Converts substrate into product.
#
# Parameters
# ------------------ ------------------ ------------------
# k
#	Synthesize rate
# k_d
#	Protein degredation
# 
# Properties
# ------------------ ------------------ ------------------
# vEnzymeSynth
#	k * this 
# degredation
#	k_d * this
# dillution
# 	mu * this
#
# Equations
# ------------------ ------------------ ------------------
# this / dt
#	vEnzymeSynth - dillution - degredation
# consume / dt
#	- vEnzymeSynth
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
				
				# Rate of dillution because of cell division
				# 
				dillution = mu * compounds[ @name ]
				
				# Rate of degration
				# 
				degration = @k_d * compounds[ @name ]
				
			# Only if the components are available 
			if ( @_test( compounds, @name, @orig, @dest ) )
				
				# Rate of Metabolism 
				# - The max speed constant v_max called v 
				# - The Enzyme itself
				# - The Compound to convert
				# - The Mihaelis-Mentin kinetics with constant k_m
				#
				vmetabolism = @v * compounds[ @name ] * ( compounds[ @orig ] / ( compounds[ @orig ] + @k_m ) )
				
			# If all components are available
			if venzymesynth?
			
				# The Enzyme increase is the rate minus dillution and degration
				#
				results[ @name ] = venzymesynth - degration - dillution
				
			# If all components are available
			if vmetabolism?
				
				results[ @orig ] = -vmetabolism
				results[ @dest ] = vmetabolism
			
			return results
		
		# Default parameters set here
		defaults = { 
		
			# Parameters
			k: 1
			k_m: 1 
			v: 1
			k_d : 1
			orig: orig
			dest: dest
			
			# Meta-Parameters
			dna: "dna"
			
			# The name
			name: name
			
			# Start Values
			starts: { name : start, dest: 0 }
		}
		
		params = _( params  ).defaults( defaults )
		super params, step

(exports ? this).Model.Metabolism = Model.Metabolism