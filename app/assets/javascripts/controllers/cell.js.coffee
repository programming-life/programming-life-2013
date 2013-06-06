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
			set: ( value ) -> 
				@view.model = value
		)

		@_previews = new View.Collection()

		@_createBindings()
		@_addInteraction() if @_interaction

	# Adds interaction to the cell
	#
	_addInteraction: () ->
		@_automagically = on
		@_addDummyViews()

	# Adds dummy modules
	#
	_addDummyViews: () ->
		
		@view.each( (view) => @view.remove view if view instanceof View.DummyModule )
		
		@view.add new View.DummyModule( @view.paper, @view, @model, Model.CellGrowth, 1 )
		@view.add new View.DummyModule( @view.paper, @view, @model, Model.DNA, 1 )
		@view.add new View.DummyModule( @view.paper, @view, @model, Model.Lipid, 1 )
		@view.add new View.DummyModule( @view.paper, @view, @model, Model.Metabolite, -1, { placement: Model.Metabolite.Outside, type: Model.Metabolite.Substrate, amount: 0, supply: 1 } )
		@view.add new View.DummyModule( @view.paper, @view, @model, Model.Metabolite, -1, { placement: Model.Metabolite.Inside, type: Model.Metabolite.Product, amount: 0, supply: 0 } )
		@view.add new View.DummyModule( @view.paper, @view, @model, Model.Transporter, -1, { direction: Model.Transporter.Inward } )
		@view.add new View.DummyModule( @view.paper, @view, @model, Model.Metabolism, -1 )
		@view.add new View.DummyModule( @view.paper, @view, @model, Model.Protein, -1 )
		@view.add new View.DummyModule( @view.paper, @view, @model, Model.Transporter, -1, { direction: Model.Transporter.Outward, transported: 'p' } )
		
		$( '.module-properties' ).click( '[data-action]', ( event ) => 
			func = @["on#{ $( event.target ).data( 'action' )}"]
			func( event ) if func?
		)


	# On Action click
	#
	# @param event [jQuery.Event] the event raised
	#
	onAction: ( event ) =>
		func = @["on#{ $( event.target ).data( 'action' )}"]
		func( event ) if func?
		
	#
	#
	onCreate: ( event ) ->
		
		
	# Creates the bindings for the cell
	#
	_createBindings: () ->
		@_bind( 'cell.module.add', @, @_onModuleAdd )		
		@_bind( 'cell.module.remove', @, @_onModuleRemove )
		@_bind( 'cell.metabolite.add', @, @_onModuleAdd )
		@_bind( 'cell.metabolite.remove', @, @_onModuleRemove )
		@_bind( 'cell.spline.add', @, @onSplineAdd)
		@_bind( 'cell.spline.remove', @, @onSplineRemove)
		@_bind( "module.creation.started", @, @_onModuleCreationStarted )
		@_bind( "module.creation.aborted", @, @_onModuleCreationAborted )
		@_bind( "module.created", @, @_onModuleCreated )
		@_bind( 'cell.module.added', @, @_onModuleAdded )
		@_bind( 'dummy.properties.change', @, @_onDummyModuleChanged)
		
	# Kills this controller
	#
	kill: () ->
		$( '.module-properties' ).off( 'click', '[data-action]', @onAction )
		return super()
			
	# Runs when module is added
	#
	# @param cell [Model.Cell] the cell
	# @param module [Model.Module] the module
	#
	_onModuleAdd: ( cell, module ) ->
		return if cell isnt @model
		@view.addModule module
			
	# Runs after module is added
	#
	# @param cell [Model.Cell] the cell
	# @param module [Model.Module] the module
	#
	_onModuleAdded: ( cell, module ) ->
		return if cell isnt @model
		return unless @_automagically
		@_automagicAdd( module )


	# Runs when module is removed
	#
	# @param cell [Model.Cell] the cell
	# @param module [Model.Module] the module
	#
	_onModuleRemove: ( cell, module ) ->
		return if cell isnt @model
		@view.removeModule module
		
	# Runs when spline is added
	#
	# @param cell [View.Cell] the cell view
	# @param spline [View.Spline] the spline
	#
	onSplineAdd: ( cell, spline ) ->
		return if cell isnt @view
		@view.addSpline spline
		
	# Runs when splice is removed
	#
	# @param cell [View.Cell] the cell view
	# @param spline [View.Spline] the spline
	#
	onSplineRemove: ( cell, spline ) ->
		return if cell isnt @view
		@view.removeSpline spline
		
	# On Module property changed add missing metabolites
	# 
	# @param module [Model.Module] the module changed
	# @param params [Array] The keys and values
	# @param key [String] the actual changed key
	# @param value [any] the new value
	# @param modulector [Constructor] the contstructor for this dummy module
	#
	_onDummyModuleChanged: ( source, params, key, value, modulector ) =>
		return unless @_automagically

		# Create a new module
		module = new modulector( _( params ).clone( true ) )

		@killPreviews()
		@preview module

	# Kill and remove all previews
	#
	killPreviews: ( ) ->
		@_previews.each( (preview) =>
			@view.remove preview
			@_trigger "module.preview.ended", preview
		)
		@_previews.kill(on)
	
	# Automagically adds the metabolite modules requires to the cell view or model
	#
	# @param module [Model.Module] The module for which to automagically add
	# @todo remove is_product
	#
	_automagicAdd: ( module ) ->
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
		missing = _( names ).filter( ( name ) => not _( @model._getModules() ).any( ( m ) -> name is m.name ) )

		for name in missing
			is_product = 
				( module instanceof Model.Transporter and module.direction is Model.Transporter.Outward ) or
				( module instanceof Model.Metabolism and name in module['dest'] )

			is_inside = name.split( '#' )[1] is 'int'
			
			if @_creating
				type = if is_product then Model.Metabolite.Product else Model.Metabolite.Substrate
				placement = if is_inside then Model.Metabolite.Inside else Model.Metabolite.Outside
				metabolite = new Model.Metabolite( { supply: 0, placement: placement, type: type }, 0, name )
				@preview metabolite
			else
				@model.addMetabolite( name, 0, 0, is_inside, is_product )
	
	# Gets called on module.creation.started
	#
	# @param source [View.DummyModule] The source of the event
	# @param module [Model.Module] The module representation of the current creation parameters
	#
	_onModuleCreationStarted: ( source, module ) ->
		type = source.getFullType()
		if source in @view.viewsByType[type]
			@_creating = on
			@preview( module )

	# Gets called on module.creation.aborted
	#
	# @param source [View.DummyModule] The source of the event
	#
	_onModuleCreationAborted: ( source ) ->
		type = source.getFullType()
		if source in @view.viewsByType[type]
			@_creating = off
			@killPreviews()
		
	# Gets called on module.creation.finished
	#
	# @param source [View.DummyModule] The source of the event
	# @param module [Model.Module] The module representation of the current creation parameters
	#
	_onModuleCreated: ( source, module ) ->
		type = source.getFullType()
		if source in @view.viewsByType[type] 
			@_creating = off
			@killPreviews()

			@model.add module
			
	# Loads a new cell into the view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback, clone = off ) ->

		setcallback = ( cell ) => 
			@model = cell 
			@_addDummyViews() if @_interaction
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
	# @param dt [Float] The timestep for the graphs
	# @param base_values [Array] continuation values
	# @param token [CancelToken] the cancellation token
	# @param interpolate [Boolean] wether to interpolate
	# @return [Object] Object with data such as An array of datapoints
	#
	solveTheSystem: ( from, to, base_values = [], token = numeric.asynccancel(), dt = 1, interpolate = off ) ->
	
		duration = to - from
		promise = @model.run( from, to, base_values, undefined, token )
		promise = promise.then( ( cell_run ) =>
			
			results = cell_run.results
			mapping = cell_run.map
	
			xValues = []
			
			# Get the interpolation for a fixed timestep instead of the adaptive timestep
			# generated by the ODE. This should be fairly fast, since the values all 
			# already there ( ymid and f )
			if interpolate
				interpolation = []
				for time in [ 0 ... duration ] by dt
					interpolation[ time ] = results.at time
				for val in [0 ... duration] by dt
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

				if interpolate
					for time in [ 0 ... duration ] by dt
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
	setSimulationState: ( startSimulateFlag, callback, t, iterations, dt ) ->
		if startSimulateFlag
			return @startSimulation( t, iterations, callback, dt )
		return @stopSimulation()
		
	# Starts the simulation
	# 
	# @param t [Integer] duration of each step call
	# @param iterations [Integer] maximum t to run
	# @param callback [Function] the callback function after each iteration
	# @param dt [Integer] graph dt
	# @return [ Tuple<CancelToken, jQuery.Promise> ] tuple of token and promise
	#
	startSimulation: ( t = 20, iterations = Cell.MAX_ITERATIONS, callback, dt = 0.001 ) ->
		
		@_running = on
		@_token = numeric.asynccancel()
		
		# This creates a version of the step function, with the parameters
		# given filled in as a partial. It is throtthed over step_update. This
		# means that you can call it an infinite number of times, but it will
		# only be executed after step_update passes.
		#
		step = _( @_step )
			.chain()
			.bind( @, dt, callback )
			.value()
		
		@_trigger( "simulation.start", @, [ @model ] )
		
		promise = @_simulate( step, t, iterations )		
		return [ @_token, promise ]
		
	# Steps the simulation
	#
	# @param t [Integer] the duration of this step
	# @param dt [Integer] the dt of the graphs
	# @param callback [Function] the callback after each iteration
	# @param base_values [Array<Float>] the previous values
	# @param max [Integer] max t
	# @return [Array<Float>] the new values
	#
	_step : ( dt, callback, from, to, base_values ) ->
	
		return base_values unless @_running
		
		promise = @solveTheSystem( from, to, base_values, @_token, dt )
		promise = promise.then( ( cell_data ) =>
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
	

	# Starts a preview for the module
	#
	# @param module [Model.Module] The module to preview
	#
	preview: ( module ) ->
		@_automagicAdd module
		@_previews.add @view.previewModule( @view , module, on )
