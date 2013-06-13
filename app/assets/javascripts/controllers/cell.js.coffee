'use strict'
# The controller for the Cell view
#
class Controller.Cell extends Controller.Base

	# Maximum number of iterations for the simulation
	#
	@MAX_ITERATIONS = 100
	
	# The minimum change required for a data point to be significant
	#
	@SIGNIFICANCE = 1e-15
	
	# Creates a new instance of Cell
	#
	# @overload constructor( paper, parent, model )
	#	Creates the cell view from parameters
	#	@param paper [Raphael] the paper
	# 	@param parent [View.*] the parent view
	# 	@param model [Model.*] the model
	#   @param interaction [Boolean] the interation
	#
	# @overload constructor( view )
	#   Sets the cell view
	#   @param view [View.Cell] the view
	#   @param interaction [Boolean] the interation
	#
	constructor: ( ) ->
		view = if arguments.length is 1
			@_interaction = on
			arguments[ 0 ]
		else
			new View.Cell( arguments[ 0 ], arguments[ 1 ], arguments[ 2 ] ? new Model.Cell(), ( @_interaction = arguments[ 3 ] ? on ) )	
		super view
				
		Object.defineProperty( @, 'model', 
			get: () -> 
				return @view.model
			set: @setCell
		)

		@addChild 'dummies', new Controller.Base( new View.Collection() )
		
		@model = @view.model
		@_createBindings()
		@_addInteraction() if @_interaction

	# Adds interaction to the cell
	#
	_addInteraction: () ->
		@_automagically = on
		return this

	# Adds dummy modules
	#
	_addDummyViews: () ->
		
		@controller( 'dummies' )?.kill()
		
		@_addDummyView( 'cellgrowth', Model.CellGrowth, 1 )
		@_addDummyView( 'lipid', Model.Lipid, 1 )
		@_addDummyView( 'dna', Model.DNA, 1 )
		@_addDummyView( 'metabolite-outside', Model.Metabolite, -1, { placement: Model.Metabolite.Outside, type: Model.Metabolite.Substrate, amount: 0, supply: 1 } )
		@_addDummyView( 'transporter-inward', Model.Transporter, -1, { direction: Model.Transporter.Inward, transported: 's'  } )
		@_addDummyView( 'metabolism', Model.Metabolism, -1 )
		@_addDummyView( 'metabolite-inside', Model.Metabolite, -1, { placement: Model.Metabolite.Inside, type: Model.Metabolite.Product, amount: 0, supply: 0 } )
		@_addDummyView( 'protein', Model.Protein, -1 )
		@_addDummyView( 'transporter-outward', Model.Transporter, -1, { direction: Model.Transporter.Outward, transported: 'p' } )
		
		return this

	# Add a dummy view
	#
	# @param id [String] the id
	# @param modulector [Function] the module constructor
	# @param number [Integer] the amount allowed or -1 for unlimited
	# @param params [Object] the defaults
	#
	_addDummyView: ( id, modulector, number, params ) ->
	
		@controller( 'dummies' ).addChild id, new Controller.DummyModule( @, modulector, number, params )
		@view.add @controller( 'dummies' ).controller( id ).view
		return this
		
	# Creates the bindings for the cell
	#
	_createBindings: () ->
		@_bind( 'cell.module.add', @, @_onModuleAdd )	
		@_bind( 'cell.module.remove', @, @_onModuleRemove )
		@_bind( 'cell.metabolite.add', @, @_onModuleAdd )
		@_bind( 'cell.metabolite.remove', @, @_onModuleRemove )
		
	# 
	#
	setCell: ( value ) ->
		@view.model = value
		for module in @view.model.getModules()
			@_onModuleAdd( value, module )
		@_addDummyViews() if @_interaction
		return this
		
	# Begin creation of a module
	#
	beginCreate: ( module ) ->
		@addChild( _( 'module-' ).uniqueId(), controller = new Controller.Module( @, module, on, @_interaction ) )
		@automagicAdd controller.model, on
		@view.add controller.view
		@stopSimulation()
		return this
		
	# End creation of a module
	#
	endCreate: ( module ) ->
		key = @findKey( ( v ) -> v.model is module ) 
		@view.remove @controller( key ).view.kill()
		@removeChild key
		@stopSimulation()
		return this
		
	# Runs when module is added
	#
	# @param cell [Model.Cell] the cell
	# @param module [Model.Module] the module
	#
	_onModuleAdd: ( cell, module ) ->
		return if cell isnt @model
		@addChild( _( 'module-' ).uniqueId(), controller = new Controller.Module( @, module, off, @_interaction ) )
		@view.add controller.view
		@stopSimulation()

	# Runs when module is removed
	#
	# @param cell [Model.Cell] the cell
	# @param module [Model.Module] the module
	#
	_onModuleRemove: ( cell, module ) ->
		return if cell isnt @model
		if key = @findKey( ( c ) -> c.model is module )
			controller = @controller( key ).kill()
			@removeChild key
			@view.remove controller.view
		@stopSimulation()
		
	# Automagically adds the metabolite modules requires to the cell view or model
	#
	# @param module [Model.Module] The module for which to automagically add
	# @todo remove is_product
	#
	automagicAdd: ( module, preview = off ) ->
		return unless @_automagically
				
		# Expand names
		names = []
		props = module.getMetaboliteProperties()
		for key, value of props
			values = if _( module[value] ).isArray() then module[value] else [ module[value] ]
			for name in values
				name = new String( name ).toString()
				continue if not name? or name.length is 0
				if name.indexOf('#') is -1
					names.push "#{name}#int"
					names.push "#{name}#ext"
				else
					names.push name

		names = _( names ).unique()

		# Find missing metabolites
		missing = _( names ).filter( ( name ) => not _( @model.getModules() ).any( ( m ) -> name is m.name ) )

		for name in missing
			is_product = 
				( module instanceof Model.Transporter and module.direction is Model.Transporter.Outward ) or
				( module instanceof Model.Metabolism and name in module['dest'] )

			is_inside = name.split( '#' )[1] is 'int'
			
			if preview
				type = if is_product then Model.Metabolite.Product else Model.Metabolite.Substrate
				placement = if is_inside then Model.Metabolite.Inside else Model.Metabolite.Outside
				metabolite = new Model.Metabolite( { supply: 0, placement: placement, type: type }, 0, name )
				@view.addPreview new View.Module( @view.paper, @view, @view.model, metabolite, on, off ) 
			else
				@model.addMetabolite( name, 0, 0, is_inside, is_product )
	
	# Loads a new cell into the view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback, clone = off ) ->

		setcallback = ( cell ) => 
			@model = cell 
			callback?.call( @, cell )
			
		@_automagically = off
		promise = Model.Cell.load cell_id, setcallback, clone
		promise.always( () => @_automagically = on )
		return promise
		
	# Saves the cell view model
	#
	# @param name the name to save with
	# @return [jQuery.Promise] the promise
	#
	save: ( name, clone = off ) ->
		@model.name = name ? @model.name
		return @model.save( clone )
		
	# Get the simulation data from the cell
	# 
	# @param from [Integer] The t0 of the simulation
	# @param to [Integer] the tn of the simulation
	# @options options [Float] dt The timestep for the graphs
	# @param base_values [Array] continuation values
	# @param token [CancelToken] the cancellation token
	# @options options [Boolean] interpolate interpolations flag
	# @options options [Integer] iterations
	# @options options [Float] tolerance
	# @return [Object] Object with data such as An array of datapoints
	#
	@catchable	
		solveTheSystem: ( from, to, base_values = [], token = numeric.asynccancel(), options = {} ) ->
		
			defaults = @getDefaultOptions()
			options = _( options ).defaults( defaults.ode )
		
			duration = to - from
			promise = @model.run( from, to, base_values, undefined, token, options )
			promise = promise.then( ( cell_run ) =>
				
				results = cell_run.results
				mapping = cell_run.map
		
				xValues = []
				
				# Get the interpolation for a fixed timestep instead of the adaptive timestep
				# generated by the ODE. This should be fairly fast, since the values all 
				# already there ( ymid and f )
				if options.interpolate
					interpolation = []
					for time in [ 0 ... duration ] by options.dt
						interpolation[ time ] = results.at time
					for val in [0 ... duration] by options.dt
						xValues.push ( val + cell_run.from )
				else
					skip = []
					prevVal = 0
					prevVal = results.x[ 0 ] - Cell.SIGNIFICANCE if results.x.length
					for index, val of results.x
						if ( Math.abs( val - prevVal ) ) >= Cell.SIGNIFICANCE
							xValues.push ( val + cell_run.from )
							prevVal = val
						else
							skip.push index
				datasets = {}			
				for key, value of mapping
					yValues = []

					if options.interpolate
						for time in [ 0 ... duration ] by options.dt
							yValues.push( interpolation[ time ][ value ] ) 
					else
						for index, substance of results.y
							unless index is _( skip ).first()
								yValues.push(substance[value])
							else
								skip.pop()
						
					datasets[ key ] = { xValues: xValues, yValues: yValues}
					
				return { 
					results: results
					datasets: datasets
					from: cell_run.from
					to: cell_run.to
				}
			)
			
			return promise
		
	# Sets the simulation state
	#
	# @param startSimulateFlag [Boolean] flag to start the simulation
	# @param callback [Function] the callback function after each iteration
	# @param t [Integer] duration of each step call
	# @param iterations [Integer] maximum t to run
	# @param dt [Integer] graph dt
	# @return [ Tuple<CancelToken, jQuery.Promise> ] tuple
	#
	setSimulationState: ( startSimulateFlag, callback, options ) ->
		if startSimulateFlag
			return @startSimulation( options.simulate ? {}, callback, options.ode ? {} )
		return @stopSimulation()
		
	# Gets default simulations options
	#
	# @return [Object] the options
	#
	getDefaultOptions: () ->
		defaults = 
			simulate:
				iteration_length: 20
				iterations: Cell.MAX_ITERATIONS
			ode:
				dt: 0.001
				tolerance: undefined
				iterations: undefined
				interpolate: off
				
		return defaults
		
	# Starts the simulation
	# 
	# @param simulate_options [Object]
	# @param ode_options [Object]
	# @options simulate_options [Integer] iteration_length duration of each step call
	# @options simulate_options [Integer] iterations maximum t to run
	# @param callback [Function] the callback function after each iteration
	# @options ode_options [Integer] dt graph dt
	# @options ode_options [Integer] tolerance 
	# @options ode_options [Integer] iterations 
	# @return [ Tuple<CancelToken, jQuery.Promise> ] tuple of token and promise
	#
	startSimulation: ( simulate_options = {}, callback, ode_options = {} ) ->
	
		defaults = @getDefaultOptions()	
		simulate_options = _( simulate_options ).defaults( defaults.simulate )
		ode_options = _( ode_options ).defaults( defaults.ode )
		
		@_running = on
		@_token = numeric.asynccancel()
		
		# This creates a version of the step function, with the parameters
		# given filled in as a partial. It is throtthed over step_update. This
		# means that you can call it an infinite number of times, but it will
		# only be executed after step_update passes.
		#
		step = _( @_step )
			.chain()
			.bind( @, ode_options, callback )
			.value()
		
		@_trigger( "simulation.start", @, [ @model ] )
		
		promise = @_simulate( step, simulate_options.iteration_length, simulate_options.iterations )		
		return [ @_token, promise ]
		
	# Steps the simulation
	#
	# @param options [Object] the ode options to feed the ode
	# @param callback [Function] the callback after each iteration
	# @param base_values [Array<Float>] the previous values
	# @param max [Integer] max t
	# @return [Array<Float>] the new values
	#
	_step : ( options, callback, from, to, base_values ) ->
	
		return base_values unless @_running
		
		promise = @solveTheSystem( from, to, base_values, @_token, options )
		
		promise = promise?.then( ( cell_data ) =>
			callback?( cell_data, cell_data.from, cell_data.to )
			return [ _( cell_data.results.y ).last(), cell_data.from, cell_data.to ]
		)
		
		return promise
	
	# Simulation handler
	#
	# Actually loops the simulation. Expects step to be a throttled function
	# and gracefully defers execution of this step function. 
	#
	# @param step [Function] the step function
	# @param t [Integer] the duration T of a step
	# @param iterations [Integer] the number of iterations/steps
	# @return [jQuery.Promise] the promise
	#
	_simulate: ( step, t, iterations ) ->
		
		# While running step this function and recursively
		# call this function. But because the call is deferred,
		# the call_stack is emptied before execution.
		#
		# @param step [Function] step function
		# @param from [Integer] the t0 of the simulation
		# @param to [Integer] the tn of the simulation
		# @param args [any*] arguments to pass
		# @return [jQuery.Promise] the promise
		#
		simulation = ( step, from, to, args ) => 
			if @_running
				promise = step( from, to, args ) 
				
				if not promise
					@stopSimulation()
					promise = $.Deferred().reject()
					return promise.promise()
					
				promise = promise.then( ( results, actual_from, actual_to ) =>
					data = results[ 0 ]
					actual_from = results[ 1 ]
					actual_to = results[ 2 ]
					@stopSimulation() if ( --iterations <= 0 )
					return simulation( step, actual_to, actual_to + t, data ) if @_running
					return null
				)
			return promise
			
		return simulation( step, 0, t, [] )
		
	# Stops the simulation
	#
	# @return [ Tuple<CancelToken, jQuery.Promise> ] tuple of token and promise
	#
	stopSimulation: ( ) ->
		@_running = off
		@_trigger( "simulation.stop", @, [ @model ] )
		return [ @_token, undefined ]
	