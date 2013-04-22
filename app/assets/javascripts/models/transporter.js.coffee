class Transporter extends Module

	# Constructor for transporters
	#
	# @param params [Object] parameters for this module
	# @param origin [String] the substrate to be transported
	# @param destination [String] the substrate after transported
	# @param start [Integer] the initial value of transporters, defaults to 0
	# @param name [String] the name of the transport, defaults to "#{origin}_to_#{destination}"
	# @option k [Integer] the subscription rate, defaults to 1
	# @option k_tr [Integer] the transportation rate, defaults to 1
	# @option v [Integer] the speed scaler (vmax), defaults to 1
	# @option dna [String] the dna to use, defaults to "dna"
	# @option orig [String] the substrate to be transported, overrides origin
	# @option dest [String] the substrate after transported, overrides destination
	# @option name [String] the name of the transporter, overrides name
	#
	constructor: ( params = {}, origin, destination, start = 0, name ) ->

		# Step function for lipids
		step = ( t, substrates ) ->
		
			if ( @test( substrates, @name, @orig ) )
				vtransport = @v * substrates[@name] * ( substrates[@orig] / ( substrates[@orig] + @k_tr ) )
			
			results = {}		
			if ( @test( substrates, @dna ) )
				results[@name] = @k * substrates[@dna]
			
			if ( vtransport? and vtransport > 0 )	
				results[@dest] = vtransport
				results[@orig] = -vtransport
				
			return results
		
		# Default parameters set here
		defaults = { 
			k: 1
			k_tr: 1
			v : 1 
			name : name ? "#{origin}_to_#{destination}"
			orig: origin
			dest: destination
			dna: "dna"
		}
		
		params = _( defaults ).extend( params )
		
		starts = {};
		starts[params.name] = start
		super params, step, starts

(exports ? this).Transporter = Transporter