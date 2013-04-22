class Model.Transporter extends Model.Module

	# Constructor for transporters
	#
	# @param params [Object] parameters for this module
	# @param origin [String] the substrate to be transported
	# @param destination [String] the substrate after transported
	# @param start [Integer] the initial value of transporters, defaults to 0
	# @param name [String] the name of the transport, defaults to "transporter_#{origin}_to_#{destination}"
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
		
			if ( @_test( substrates, @name, @orig ) )
				vtransport = @v * substrates[@name] * ( substrates[@orig] / ( substrates[@orig] + @k_tr ) )
			
			results = {}		
			if ( @_test( substrates, @dna ) )
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
			name : name ? "transporter_#{origin}_to_#{destination}"
			orig: origin
			dest: destination
			dna: "dna"
		}
		
		params = _( defaults ).extend( params )
		
		starts = {};
		starts[params.name] = start
		starts[params.dest] = 0
		super params, step, starts
		
	# Generator for transporter to internal cell
	#
	# @param params [Object] parameters for this module
	# @param substrate [String] the substrate to be transported, defaults to "s"
	# @param orig_post [String] the substrate name postfix before transport
	# @param dest_post [String] the substrate name postfix after transport
	# @param start [Integer] the initial value of transporters, defaults to 0
	# @option k [Integer] the subscription rate, defaults to 1
	# @option k_tr [Integer] the transportation rate, defaults to 1
	# @option v [Integer] the speed scaler (vmax), defaults to 1
	# @option dna [String] the dna to use, defaults to "dna"
	# @option orig [String] the substrate to be transported, overrides substrate + orig_post
	# @option dest [String] the substrate after transported, overrides substrate + dest_post
	# @option name [String] the name of the transporter, defaults to "transporter_#{substrate}_in"
	#
	@int : ( params = { }, substrate = "s", start = 0, orig_post = "_ext", dest_post = "_int" ) ->
		return new Model.Transporter( params, "#{substrate}#{orig_post}", "#{substrate}#{dest_post}", start, "transporter_#{substrate}_in" )
	
	# Generator for transporter from internal cell
	#
	# @param params [Object] parameters for this module
	# @param substrate [String] the substrate to be transported, defaults to "p"
	# @param orig_post [String] the substrate name postfix before transport
	# @param dest_post [String] the substrate name postfix after transport
	# @param start [Integer] the initial value of transporters, defaults to 0
	# @option k [Integer] the subscription rate, defaults to 1
	# @option k_tr [Integer] the transportation rate, defaults to 1
	# @option v [Integer] the speed scaler (vmax), defaults to 1
	# @option dna [String] the dna to use, defaults to "dna"
	# @option orig [String] the substrate to be transported, overrides substrate + orig_post
	# @option dest [String] the substrate after transported, overrides substrate + dest_post
	# @option name [String] the name of the transporter, defaults to "transporter_#{substrate}_out"
	#
	@ext : ( params = { }, substrate = "p", start = 0, orig_post = "_int", dest_post = "_ext" ) ->
		return new Model.Transporter( params, "#{substrate}#{orig_post}", "#{substrate}#{dest_post}", start, "transporter_#{substrate}_out" )
		
(exports ? this).Model.Transporter = Model.Transporter