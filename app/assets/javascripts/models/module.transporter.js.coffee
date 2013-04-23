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
		step = ( t, substrates, mu ) ->
		
			if ( @_test( substrates, @name, @orig ) )
				rate = if @k_tr isnt 0 then ( substrates[@orig] / ( substrates[@orig] + @k_tr ) ) else substrates[@orig]
				vtransport = @v * substrates[@name] * rate
			
			results = {}		
			if ( @_test( substrates, @dna, @consume ) )
				vtransportsynth = @k * substrates[@dna] * substrates[@consume]
				results[@name] = vtransportsynth - mu * ( substrates[@name] ? 0 )
			
			# todo: difference between vtrans in and out?
			if ( vtransport? and vtransport > 0 )
				m = if @direction is 1 then substrates[@cell] else 1 
				results[@dest] = vtransport
				results[@orig] = -vtransport * m
				
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
			cell: "cell"
		}
		
		@_dir = dir
		Object.defineProperty( @, 'direction',
			get: ->
				return @_dir
			set: (value) ->
				@_dir = value
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
	@ext : ( params = { k_tr: 0 }, start = 0, substrate = "p", orig_post = "_int", dest_post = "_ext" ) ->
		return new Model.Transporter( params, start, "#{substrate}#{orig_post}", "#{substrate}#{dest_post}", "transporter_#{substrate}_out", -1 )
		
(exports ? this).Model.Transporter = Model.Transporter