class Model.Transporter extends Model.Module

	# Constructor for transporters
	#
	# @param params [Object] parameters for this module
	# @param origin [String] the substrate to be transported
	# @param destination [String] the substrate after transported
	# @param start [Integer] the initial value of transporters, defaults to 1
	# @param name [String] the name of the transport, defaults to "transporter_#{origin}_to_#{destination}"
	# @param food [String] the substrate to consume, defauls to "s_int"
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [Integer] k_tr the transportation rate, defaults to 1
	# @option params [Integer] v the speed scaler (vmax), defaults to 1
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [String] orig the substrate to be transported, overrides origin
	# @option params [String] dest the substrate after transported, overrides destination
	# @option params [String] name the name of the transporter, overrides name
	# @option params [String] consume the substrate to be consumed, overides food
	#
	constructor: ( params = {}, start = 1, origin, destination, name,  dir = 0, food = "s_int" ) ->

		# Step function for lipids
		step = ( t, substrates ) ->
		
			if ( @_test( substrates, @name, @orig ) )
				vtransport = @v * substrates[@name] * ( substrates[@orig] / ( substrates[@orig] + @k_tr ) )
			
			results = {}		
			if ( @_test( substrates, @dna, @consume ) )
				results[@name] = @k * substrates[@dna] * substrates[@consume]
			
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
			consume: food
		}
		
		Object.defineProperty( @, 'direction',
			get: ->
				return dir
		)
		
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
	# @param start [Integer] the initial value of transporters, defaults to 1
	# @option k [Integer] the subscription rate, defaults to 1
	# @option k_tr [Integer] the transportation rate, defaults to 1
	# @option v [Integer] the speed scaler (vmax), defaults to 1
	# @option dna [String] the dna to use, defaults to "dna"
	# @option orig [String] the substrate to be transported, overrides substrate + orig_post
	# @option dest [String] the substrate after transported, overrides substrate + dest_post
	# @option name [String] the name of the transporter, defaults to "transporter_#{substrate}_in"
	#
	@int : ( params = { }, start = 1, substrate = "s", orig_post = "_ext", dest_post = "_int" ) ->
		return new Model.Transporter( params, start, "#{substrate}#{orig_post}", "#{substrate}#{dest_post}", "transporter_#{substrate}_in", 1 )
	
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
	@ext : ( params = { }, start = 0, substrate = "p", orig_post = "_int", dest_post = "_ext" ) ->
		return new Model.Transporter( params, start, "#{substrate}#{orig_post}", "#{substrate}#{dest_post}", "transporter_#{substrate}_out", -1 )
		
(exports ? this).Model.Transporter = Model.Transporter