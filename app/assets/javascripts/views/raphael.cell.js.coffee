#  Class to generate a view for a cell model
#
class View.Cell extends View.RaphaelBase

	@concern Mixin.EventBindings

	MAX_RUNTIME: 100

	# Constructor for this view
	# 
	# @param paper [Raphael] paper parent
	# @param cell [Model.Cell] cell to view
	# 	
	constructor: ( paper, cell, container = "#graphs" ) ->
		super(paper)
		
		container =  if $( container )[0] then $( container )[0] else $("<div></div>")[0]
		@_container = Raphael( container, "100%", 1 )
		@_container.setViewBox( 0, 0, 1000, 1000 ) # 1000 pixels, 1000 pixels

		@_views = []
		@_drawn = []
		@_graphs = {}
		@_numGraphs = 0

		@_width = @_paper.width
		@_height = @_paper.height
		
		@_allowEventBindings()
		
		Object.defineProperty( @ , "_cell",
			value: undefined
			configurable: false
			enumerable: false
			writable: true
		)
		
		Object.defineProperty( @, 'cell',
			
			get: -> @_cell
			
			set: ( value ) ->
			
				@kill()
				
				@_cell = value
				for module in @_cell._modules
					@_views.push new View.Module( @_paper, @, @_cell, module)
			
				@_createButtons()
				@_bind( 'cell.add.module', @, @onModuleAdd )
				@_bind( 'cell.add.metabolite', @, @onModuleAdd )
				@_bind( 'cell.remove.module', @, @onModuleRemove )
				@_bind( 'cell.remove.metabolite', @, @onModuleRemove )
				
				@_notificationsView = new View.Notification( @, @cell )
				
			configurable: false
			enumerable: true
		)
				
		@cell = cell		
	#
	#
	kill: () ->
		@_notificationsView?.kill()
		
		if @_views?
			for view in @_views
				view.kill?()
		
		if @_graphs?
			for name, graph of @_graphs
				graph.clear()
				
		@_unbindAll()
		
		@_drawn = []
		@_views = []
		@_graphs = {}
		@_numGraphs = 0
		
	#
	#
	getBBox: ( ) -> 
		return @_contents?.getBBox() ? { x:0, y:0, x2:0, y2:0, width:0, height:0 }
		
	#
	# @todo hide buttons if module present etc.
	#
	_createButtons: () ->
		
		@_views.push new View.DummyModule( @_paper, @, @_cell, new Model.DNA() )
		@_views.push new View.DummyModule( @_paper, @, @_cell, new Model.Lipid() )
		@_views.push new View.DummyModule( @_paper, @, @_cell, new Model.Metabolite( { name: 's' } ), { name: 's', inside_cell: false, is_product: false, amount: 1, supply: 1 } )
		@_views.push new View.DummyModule( @_paper, @, @_cell, Model.Transporter.int(), { direction: Model.Transporter.Inward } )
		@_views.push new View.DummyModule( @_paper, @, @_cell, new Model.Metabolism() )
		@_views.push new View.DummyModule( @_paper, @, @_cell, new Model.Protein() )
		@_views.push new View.DummyModule( @_paper, @, @_cell, Model.Transporter.ext(), { direction: Model.Transporter.Outward } )
			
		#@_views.push new View.Tree( @_paper, @_cell._tree)
		
		@_views.push new View.Play( @_paper, @ )
		
	# Redraws the cell
	# 		
	redraw: () ->
		@draw( @_x, @_y, @_scale )

	# Draws the cell
	# 
	# @param x [Integer] x location
	# @param y [Integer] y location
	# @param scale [Integer] scale
	#
	draw: ( x, y, scale ) ->
		@clear()
	
		@_x = x
		@_y = y
		@_scale = scale

		radius = @_scale * 400

		@_shape = @_paper.circle( x, y, radius )
		@_shape.node.setAttribute( 'class', 'cell' )
		@_shape.attr
			cx: x
			cy: y
			r: radius
		@_contents.push @_shape
				
		counters = {}
		
		# Draw each module
		for view in @_views when view.visible
			
			if ( view instanceof View.Module )
				
				type = view.module.constructor.name
				direction = if view.module.direction? then view.module.direction else 0
				placement = if view.module.placement? then view.module.placement else 0
				placement_type = if view.module.type? and type is "Metabolite" then view.module.type else 0
				counter_name = "#{type}_#{direction}_#{placement}_#{placement_type}"
				counter = counters[ counter_name ] ? 0

				# Send all the parameters through so the location
				# method becomes functional. Easier to test and debug.
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
				
				placement = @getLocationForModule( view.module, params )
				
				counters[ counter_name ] = ++counter
				
			if ( view instanceof View.Play )
				placement = 
					x: x
					y: y

			if (view instanceof View.Tree )
				placement = {x: 300, y: 100}

			view.draw( placement.x, placement.y, scale )
		
	# On module added, add it from the cell
	# 
	# @param cell [Model.Cell] cell added to
	# @param module [Model.Module] module added
	#
	onModuleAdd: ( cell, module ) =>
		unless cell isnt @_cell
			unless _( @_drawn ).indexOf( module.id ) isnt -1
				@_drawn.unshift module.id
				@_views.unshift new View.Module( @_paper, @, @_cell, module )
				@redraw()
			
	# On module removed, removed it from the cell
	# 
	# @param cell [Model.Cell] cell removed from
	# @param module [Model.Module] module removed
	#
	onModuleRemove: ( cell, module ) =>
		index = _( @_drawn ).indexOf( module.id )
		if index isnt -1
			view = @_views[ index ].kill()
			@_views = _( @_views ).without view
			@_drawn = _( @_drawn ).without module.id
			@redraw()

	# Returns the location for a module
	#
	# @param module [Model.Module] the module to get the location for
	# @return [Object] the size as an object with x, y
	#
	getLocationForModule: ( module, params ) ->
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
		for view in @_views
			return view if view.module is module

		return false
	
	# Get the simulation data from the cell
	# 
	# @param duration [Integer] The duration of the simulation
	# @param dt [Float] The timestep for the graphs
	# @param base_values [Array] continuation values
	# @return [Object] Object with data such as An array of datapoints
	#
	_getCellData: ( duration, base_values = [], dt = 1, iteration = 0 ) ->
	
		cell_run = @_cell.run( duration, base_values, iteration )
		
		results = cell_run.results
		mapping = cell_run.map
		
		# This keeps track of where in the simulation we are. If we provide base values
		# and an iteration number, we can keep track of where the duration is located
		iteration = iteration + 1
		iteration = 1 unless cell_run.append

		# Get the interpolation for a fixed timestep instead of the adaptive timestep
		# generated by the ODE. This should be fairly fast, since the values all 
		# already there ( ymid and f )
		interpolation = []
		for time in [ 0 .. duration ] by dt
			interpolation[ time ] = results.at time;

		datasets = {}
		
		for key, value of mapping
			dataset = []
			
			# Push all the values
			for time in [ 0 .. duration ] by dt
				dataset.push( interpolation[ time ][ value ] ) 
				
			datasets[ key ] = dataset

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
	
		console.log basex, basey
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
	# @param scale [Integer] scale
	# @return [Object] graphs
	#
	_drawGraphs: ( datasets, x, y, scale, append = off ) ->
	
		graph_num = 0
		
		for key, graph of @_graphs
			graph.clear()
			delete @_graphs[ key ] unless datasets[ key ]?
		
		for key, dataset of datasets
			if ( !@_graphs[ key ]? )
				height = y + 100 + Math.ceil( (graph_num + 1) / 2 ) * 175 + ( Math.ceil( (graph_num + 1) / 2 ) - 1 ) * 100
				@_container.setViewBox( 0, 0, 1000, height )
				@_container.setSize( "100%", height )
				@_graphs[ key ] = new View.Graph( @_container, key, @ )

			
			@_graphs[ key ].appendData( dataset ) if append
			@_graphs[ key ].addData( dataset ) unless append
			
			placement = @_getGraphPlacement( x, y, scale, graph_num++ )
			@_graphs[ key ].draw( placement.x, placement.y, scale )
			
		
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
	# @param dt [Integer] graph dt
	#
	startSimulation: ( step_duration = 20, step_update = 2000, dt = 1 ) ->
		
		@_running = on
		@_iteration = 0
		
		console.log 'starting simulation'

		# This creates a version of the step function, with the parameters
		# given filled in as a partial. It is throtthed over step_update. This
		# means that you can call it an infinite number of times, but it will
		# only be executed after step_update passes.
		step = _( @_step )
			.chain()
			.bind( @, step_duration, dt )
			.throttle( step_update )
			.value()
		
		# Actually simulate
		@_simulate( step )
	
		Model.EventManager.trigger("simulation.start",@, [ @_cell ])
		
		return this
		
	# Steps the simulation
	#
	# @param duration [Integer] the duration of this step
	# @param dt [Integer] the dt of the graphs
	# @param base_values [Array<Float>] the previous values
	# @return [Array<Float>] the new values
	#
	# @todo stopSimulation should throw event that is captured by play button
	#
	_step : ( duration, dt, base_values ) ->
		
		cell_data = @_getCellData( duration, base_values, dt, @_iteration )
		@_iteration = cell_data.iteration
		
		@_drawGraphs( cell_data.datasets, 0, 0, @_scale, @_iteration > 1  )

		if cell_data.to >= @MAX_RUNTIME
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
		
			if @_running
				results = step( args )
				_.defer( simulation, step, results )
			
		# At the end of the call stack, start the simulation loop
		_.defer( simulation, step, [] )
		
	# Stops the simulation
	#
	stopSimulation: ( ) ->
	
		console.log 'stop'
		
		@_running = off
		@_redrawGraphs()

		Model.EventManager.trigger("simulation.stop",@, [ @_cell ])
		return this


	# Draws red lines
	#
	# @param x [Integer] x position
	#
	_drawRedLines: ( x ) ->
		for key, graph of @_graphs
			graph._drawRedLine( x )
			
(exports ? this).View.Cell = View.Cell