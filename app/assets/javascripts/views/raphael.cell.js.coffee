# Class to generate a view for a cell model
#
# @concern Mixin.EventBindings
#
class View.Cell extends View.RaphaelBase

	@concern Mixin.EventBindings

	@MAX_RUNTIME: 50

	# Constructor for this view
	# 
	# @param paper [Raphael] paper parent
	# @param parent [View.RaphaelBase] base view
	# @param cell [Model.Cell] cell to view
	# @param container [String] container element for the strings 
	# 	
	constructor: ( paper, parent, cell, container = "#graphs", @_interaction = on ) ->
		super paper, parent

		@_container =  if $( container )[0] then $( container ) else $("<div id='graphs-#{_.uniqueId()}'></div>")
		@_container.data( 'cell', Model.Cell.extractId( cell ).id )
		
		@_drawn = []
		@_graphs = {}
		@_numGraphs = 0

		@_width = @_paper.width
		@_height = @_paper.height
		
		@_allowEventBindings()
		@_defineAccessors()
		@model = cell		
		@_interpolation = off
		
	# Defines the accessors for this view
	#
	_defineAccessors: () ->
		
		Object.defineProperty( @ , "_model",
			value: undefined
			configurable: false
			enumerable: false
			writable: true
		)
		
		Object.defineProperty( @, 'model',
			get: -> @_model
			set: @setCell
		)
		
	# Sets the displayed cell to value
	#
	# @param value [Model.Cell] the cell to display
	#
	setCell: ( value ) ->
			
		@kill()
		
		@_model = value
		for module in @_model._getModules()
			view = new View.Module( @_paper, @, @_model, module, @_interaction )
			@_views.push view
			@_drawn.push [ { model: module, view: view } ]
		
		@_addInteraction() if @_interaction
		@_bind( 'cell.add.module', @, @onModuleAdd )
		@_bind( 'cell.add.metabolite', @, @onModuleAdd )
		@_bind( 'cell.remove.module', @, @onModuleRemove )
		@_bind( 'cell.remove.metabolite', @, @onModuleRemove )
		
		@_trigger( 'view.cell.set', @, [ @model ] )

		@redraw() if @_x? and @_y?
		return this
		
	# Adds interaction to the cell
	#
	_addInteraction: () ->
		@_createButtons()
		@_notificationsView = new View.CellNotification( @, @_model )
	
	# Kills the cell view by resetting itself and its children
	#
	kill: () ->
		super()
		
		@_notificationsView?.kill()

		if @_graphs?
			for name, graph of @_graphs
				graph.clear()
		
		@_container.empty()
		
		@_drawn = []
		@_views = []
		@_graphs = {}
		@_numGraphs = 0
		
	# Creates the interaction buttons
	# 
	_createButtons: () ->
		
		@_views.push new View.DummyModule( @_paper, @, @_model, Model.CellGrowth, 1 )
		@_views.push new View.DummyModule( @_paper, @, @_model, Model.DNA, 1 )
		@_views.push new View.DummyModule( @_paper, @, @_model, Model.Lipid, 1 )
		@_views.push new View.DummyModule( @_paper, @, @_model, Model.Metabolite, -1, { name: 's', placement: Model.Metabolite.Outside, type: Model.Metabolite.Substrate, amount: 1, supply: 1 } )
		@_views.push new View.DummyModule( @_paper, @, @_model, Model.Transporter, -1, { direction: Model.Transporter.Inward, transported: 's' } )
		@_views.push new View.DummyModule( @_paper, @, @_model, Model.Metabolism, -1 )
		@_views.push new View.DummyModule( @_paper, @, @_model, Model.Protein, -1 )
		@_views.push new View.DummyModule( @_paper, @, @_model, Model.Transporter, -1, { direction: Model.Transporter.Outward, transported: 'p' } )

	# Returns the bounding box of this view
	#
	# @return [Object] a bounding box object with coordinates
	#
	getBBox: ( ) -> 
		return @_shape?.getBBox() ? { x:0, y:0, x2:0, y2:0, width:0, height:0 }

	# Returns the coordinates of either the entrance or exit of this view
	#
	# @param location [View.Module.Location] the location (entrance or exit)
	# @return [[float, float]] a tuple of the x and y coordinates
	#
	getPoint: ( location ) ->
		box = @getBBox()

		switch location
			when View.Module.Location.Left
				return [box.x ,@y]
			when View.Module.Location.Right
				return [box.x2 ,@y]
			when View.Module.Location.Top
				return [@x, box.y]
			when View.Module.Location.Bottom
				return [@x, box.y2]

	#
	#
	getAbsolutePoint: ( location ) ->
		[x, y] = @getPoint(location)
		return @getAbsoluteCoords(x, y)
		
	# Redraws the cell
	# 		
	redraw: () ->
		@draw( @_x, @_y )
	
	# Gets modules placement for a module view
	# 
	# @param view [View.Module, View.DummyModule] the view to get the placement for
	# @param x [Integer] base x
	# @param y [Integer] base y
	# @param radius [Integer] radius of the cell
	# @param scale [Integer] the scale
	# @param counters [Object] counter object to keep track what is drawn
	# @return [Object] the placement object
	#
	_getModulePlacement: ( view, x, y, radius, scale, counters = {} ) ->
	
		type = view.type
		direction = if view.module.direction? then view.module.direction else 0
		placement = if view.module.placement? then view.module.placement else 0
		placement_type = if view.module.type? and type is "Metabolite" then view.module.type else 0
		counter_name = "#{type}_#{direction}_#{placement}_#{placement_type}"
		counter = counters[ counter_name ] ? 0

		params = { 
			count: counter
			view: view
			type: type 
			direction: direction
			placement: placement
			placement_type: placement_type
			cx: x
			cy: y
			r: radius
			scale: scale
		}
				
		counters[ counter_name ] = ++counter
		
		return @getLocationForModule( params )
		
	# Draws the cell on coordinates
	# 
	# @param x [Integer] the center x position
	# @param y [Integer] the center y position
	# @param radius [Integer] radius of the cell
	# @return [Raphael] the cell shape
	#
	_drawCell: ( x, y, radius ) ->
		@_shape = @_paper.circle( x, y, radius )
		@_shape.node.setAttribute( 'class', 'cell' )
		@_shape.attr
			cx: x
			cy: y
			r: radius
		@_contents.push @_shape
		return @_shape
		
	# Draws the child views
	# 
	# @param x [Integer] the center x position
	# @param y [Integer] the center y position
	# @param scale [Integer] the scale
	# @param radius [Integer] the radius of the cell
	#
	_drawViews: ( x, y, radius, scale ) ->
	
		counters = {}
		
		for view in @_views when view.visible
			if ( view instanceof View.Module or view instanceof View.DummyModule)
				placement = @_getModulePlacement( view, x, y, radius, scale, counters )
			if ( view instanceof View.Play )
				placement = { x: x, y: y }
			if ( view instanceof View.Tree )
				placement = { x: 300, y: 100 }

			view.draw( placement?.x, placement?.y, scale )

	# Draws the cell
	# 
	# @param x [Integer] x location
	# @param y [Integer] y location
	#
	draw: (  @_x = 0, @_y = 0, radius = 400 ) ->
		@clear()

		@_drawCell( @_x, @_y, radius )
		@_drawViews( @_x, @_y, radius, 1 )
		
	# On module added, add it from the cell
	# 
	# @param cell [Model.Cell] cell added to
	# @param module [Model.Module] module added
	#
	onModuleAdd: ( cell, module ) =>
		unless cell isnt @_model
			unless ( _( @_drawn ).find( ( d ) -> d.model is module ) )?
				view = new View.Module( @_paper, @, @_model, module, @_interaction )
				@_drawn.unshift { model: module, view: view }
				@_views.unshift view
				@redraw()
			
	# On module removed, removed it from the cell
	# 
	# @param cell [Model.Cell] cell removed from
	# @param module [Model.Module] module removed
	#
	onModuleRemove: ( cell, module ) =>
		if ( drawn = _( @_drawn ).find( ( d ) -> d.model is module ) )?
			view = drawn.view.kill()
			@_views = _( @_views ).without view
			@_drawn = _( @_drawn ).without drawn
			@redraw()

	# Returns the location for a module
	#
	# @return [Object] the size as an object with x, y
	#
	getLocationForModule: ( params ) ->
		x = 0
		y = 0
		
		switch params.type
		
			when "CellGrowth"
				alpha = -3 * Math.PI / 4 + ( ( params.count + 1 ) * Math.PI / 12 )
				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )
			
			when "Lipid"
				alpha = -3 * Math.PI / 4 + ( params.count * Math.PI / 12 )
				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )

			when "Transporter"
				dx = 80 * params.count * params.scale
				
				alpha = 0
				if params.direction is Model.Transporter.Inward					
					alpha = Math.PI - Math.asin( dx / params.r )
				if params.direction is Model.Transporter.Outward		
					alpha = Math.asin( dx / params.r )

				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )

			when "DNA"
				x = params.cx + ( params.count % 3 * 40 )
				y = params.cy - params.r / 2 + ( Math.floor( params.count / 3 ) * 40 )

			when "Metabolism"
				x = params.cx + ( params.count % 2 * 130 )
				y = params.cy + params.r / 2 + ( Math.floor( params.count / 2 ) * 60 )

			when "Protein"
				x = params.cx + params.r / 2 + ( params.count % 3 * 40 )
				y = params.cy - params.r / 2 + ( Math.floor( params.count / 3 ) * 40 )
				
			when "Metabolite"

				x = params.cx
				if params.placement is Model.Metabolite.Inside
					if params.placement_type is Model.Metabolite.Substrate
						x = x - 200 * params.scale
					if params.placement_type is Model.Metabolite.Product
						x = x + 200 * params.scale
				else if params.placement is Model.Metabolite.Outside
					if params.placement_type is Model.Metabolite.Substrate
						x = x - params.r - 200 * params.scale
					if params.placement_type is Model.Metabolite.Product
						x = x + params.r + 200 * params.scale

				y = params.cy + ( Math.round( params.count ) * 100 * params.scale )
				
		return { x: x, y: y }

	# Get module view for the given module
	#
	# @param module [Module] the module for which to return the view
	# @return [Module.View] the view which represents the given module
	#
	getView: ( module ) ->
		return _( @_drawn ).find( ( d ) -> d.model is module )?.view
	
	# Get the simulation data from the cell
	# 
	# @param duration [Integer] The duration of the simulation
	# @param dt [Float] The timestep for the graphs
	# @param base_values [Array] continuation values
	# @return [Object] Object with data such as An array of datapoints
	#
	_getCellData: ( duration, base_values = [], dt = 1, iteration = 0 ) ->
	
		cell_run = @_model.run( duration, base_values, iteration )
		
		results = cell_run.results
		mapping = cell_run.map
		
		# This keeps track of where in the simulation we are. If we provide base values
		# and an iteration number, we can keep track of where the duration is located
		iteration = iteration + 1
		iteration = 1 unless cell_run.append

		# Get the interpolation for a fixed timestep instead of the adaptive timestep
		# generated by the ODE. This should be fairly fast, since the values all 
		# already there ( ymid and f )
		if @_interpolation?
			interpolation = []
			for time in [ 0 .. duration ] by dt
				interpolation[ time ] = results.at time;

		datasets = {}

		xValues = []
		for val in results.x
			xValues.push (val + ((iteration - 1) * duration))

		for key, value of mapping
			yValues = []

			if @_interpolation
				for time in [ 0 .. duration ] by dt
					yValues.push( interpolation[ time ][ value ] ) 
			else
				for substance in results.y
					yValues.push(substance[value])
				
			datasets[ key ] = [xValues,yValues]

		return { 
			results: results
			datasets: datasets
			from: duration * ( iteration - 1 )
			to: ( duration * iteration )
			iteration: iteration
		}
			
	
	# Get the graph placement
	# 
	# @return [Object] A placement object
	# @todo why is there width/height code here? should come from graph
	#
	_getGraphPlacement: ( basex, basey, scale, graph_num ) ->
	
		x = basex + 100
		y = basey + 50
		
		unless graph_num is 0
			width = 350 
			height = 175
			padding_x = 200
			padding_y = 100
			x += ( width + padding_x ) * ( graph_num % 2 )
			y += ( height + padding_y ) * Math.floor( graph_num / 2 ) 
		
		return {
			x: x
			y: y
		}
		

	# Draw the graphs with the data from the datasets
	#
	# @param datasets [Object] An object of datasets
	# @param x [Integer] x location to draw
	# @param y [Integer] y location to draw
	# @return [Object] graphs
	#
	_drawGraphs: ( datasets, x, y, append = off ) ->
	
		graph_num = 0
		
		for key, graph of @_graphs
			graph.clear()
			delete @_graphs[ key ] unless datasets[ key ]?
		
		for key, dataset of datasets
			if ( !@_graphs[ key ]? )
				@_graphs[ key ] = new View.Graph( @_container, key, @ )

			
			@_graphs[ key ].appendData( dataset ) if append
			@_graphs[ key ].addData( dataset ) unless append
			@_graphs[ key ].draw( )

			#@_graphs[ key ].play( undefined, 2500)
			
		
		return @_graphs
	
	# Redraw graphs
	#
	_redrawGraphs: ( ) ->
		for graph in @_graphs
			graph.redraw()
			
	
	# Starts drawing the simulation
	# 
	# @param step_duration [Integer] duration of each step call
	# @param step_update [Integer] time between steps
	# @param max [Integer] max t
	# @param dt [Integer] graph dt
	#
	startSimulation: ( step_duration = 20, step_update = 2000, max = View.Cell.MAX_RUNTIME, dt = 1 ) ->
		
		@_running = on
		@_iteration = 0
		
		console.log 'starting simulation'

		# This creates a version of the step function, with the parameters
		# given filled in as a partial. It is throtthed over step_update. This
		# means that you can call it an infinite number of times, but it will
		# only be executed after step_update passes.
		step = _( @_step )
			.chain()
			.bind( @, step_duration, dt, max )
			.throttle( step_update )
			.value()
		
		# Actually simulate
		@_simulate( step )
	
		@_trigger("simulation.start",@, [ @_model ])
		
		return this
		
	# Steps the simulation
	#
	# @param duration [Integer] the duration of this step
	# @param dt [Integer] the dt of the graphs
	# @param base_values [Array<Float>] the previous values
	# @param max [Integer] max t
	# @return [Array<Float>] the new values
	#
	# @todo stopSimulation should throw event that is captured by play button
	#
	_step : ( duration, dt, max, base_values ) ->
	
		return base_values unless @_running
		
		cell_data = @_getCellData( duration, base_values, dt, @_iteration )
		@_iteration = cell_data.iteration
		
		@_drawGraphs( cell_data.datasets, 0, 0, @_iteration > 1  )

		if cell_data.to >= max
			@stopSimulation()
			
		return _( cell_data.results.y ).last()
	
	# Simulation handler
	#
	# Actually loops the simulation. Expects step to be a throttled function
	# and gracefully defers execution of this step function. 
	#
	_simulate: ( step ) ->
		
		console.log 'simulate'
		
		# While running step this function and recursively
		# call this function. But because the call is deferred,
		# the call_stack is emptied before execution.
		#
		# @param step [Function] step function
		# @param results [any*] arguments to pass
		simulation = ( step, args ) => 
		
			results = step( args ) if @_running
			_.defer( simulation, step, results ) if @_running
			
		# At the end of the call stack, start the simulation loop
		_.defer( simulation, step, [] )
		
	# Stops the simulation
	#
	stopSimulation: ( ) ->
	
		console.log 'stop'
		
		@_running = off

		@_trigger("simulation.stop",@, [ @_model ])
		return this

	# Loads a new cell into this view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback ) ->
		
		setcallback = ( cell ) => 
			@model = cell 
			callback?.call( @, cell )
			
		return Model.Cell.load cell_id, setcallback
		
	# Saves the cell view model
	#
	# @return [jQuery.Promise] the promise
	#
	save: () ->
		return @model.save()

	# Draws red lines
	#
	# @param x [Integer] x position
	#
	_drawRedLines: ( x ) ->
		for key, graph of @_graphs
			graph._drawRedLine( x )
