class View.Cell

	constructor: ( paper, cell ) ->
		@_paper = paper
		@_cell = cell

		@_views = []
		@_drawn = []
		@_graphs = {}
		@_numGraphs = 0

		@_width = @_paper.width
		@_height = @_paper.height

		if ( @_cell? )
			for module in @_cell._modules
				@_views.push new View.Module( @_paper, module)

		@_views.push new View.DummyModule( @_paper, @_cell, new Model.DNA() )
		@_views.push new View.DummyModule( @_paper, @_cell, new Model.Lipid() )
		@_views.push new View.DummyModule( @_paper, @_cell, new Model.Metabolite( { placement: -1, name: 's' } ), { name: 's_ext', inside_cell: off, is_product: off, amount: 1 } )
		@_views.push new View.DummyModule( @_paper, @_cell, Model.Transporter.int(), { direction: 1 } )
		@_views.push new View.DummyModule( @_paper, @_cell, new Model.Metabolism() )
		@_views.push new View.DummyModule( @_paper, @_cell, new Model.Protein() )
		@_views.push new View.DummyModule( @_paper, @_cell, Model.Transporter.ext(), { direction: -1 } )
		
		
		@_views.push new View.Play( @_paper, @)
		
		Model.EventManager.on( 'cell.add.module', @, @onModuleAdd )
		Model.EventManager.on( 'cell.add.substrate', @, @onModuleAdd )
		Model.EventManager.on( 'cell.remove.module', @, @onModuleRemove )
			

	# Draws the cell
	#
	draw: (x, y, scale ) ->
		@_x = x
		@_y = y
		@_scale = scale

		radius = @_scale * 400

		unless @_shape
			@_shape = @_paper.circle( @_x, @_y, radius )
			@_shape.node.setAttribute( 'class', 'cell' )
		else
			@_shape.attr
				cx: @_x
				cy: @_y
				r: radius
				
		counters = {}
		
		# Draw each module
		for view in @_views
			
			unless view.visible
				continue
			
			if ( view instanceof View.Module )
				type = view.module.constructor.name
				direction = view.module.direction ? view.module.placement ? 0
				counter = counters[ "#{type}_#{direction}" ] ? 0
				
				# Send all the parameters through so the location
				# method becomes functional. Easier to test and debug.
				params = { 
					count: counter
					view: view
					type: type 
					placement: direction
					cx: @_x
					cy: @_y
					r: radius
					scale: @_scale
				}
				
				placement = @getLocationForModule( view.module, params )
				
				counters[ "#{type}_#{direction}" ] = ++counter
				
			if ( view instanceof View.Play )
				placement = { x: @_x, y: @_y, @_scale }

			view.draw( placement.x, placement.y, @_scale )
		
	# On module added, add it from the cell
	# 
	# @param cell [Model.Cell] cell added to
	# @param module [Model.Module] module added
	#
	onModuleAdd: ( cell, module ) =>
		unless cell isnt @_cell
			unless _( @_drawn ).indexOf( module.id ) isnt -1
				@_drawn.unshift module.id
				@_views.unshift new View.Module( @_paper, module )
				@draw(@_x, @_y, @_scale)
			
	# On module removed, removed it from the cell
	# 
	# @param cell [Model.Cell] cell removed from
	# @param module [Model.Module] module removed
	#
	onModuleRemove: ( cell, module ) =>
		index = _( @_drawn ).indexOf( module.id )
		if index isnt -1
			view = @_views[ index ]
			view.clear()
			@_views = _( @_views ).without view
			@_drawn = _( @_drawn ).without module.id
			
			@draw(@_x, @_y, @_scale)

	# Returns the location for a module
	#
	# @param module [Model.Module] the module to get the location for
	# @returns [Object] the size as an object with x, y
	#
	getLocationForModule: ( module, params ) ->
		x = 0
		y = 0
		
		switch params.type
		
			when "CellGrowth"
				alpha = 3 * Math.PI / 4 + ( params.count * Math.PI / 12 )
				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )
			
			when "Lipid"
				alpha = -3 * Math.PI / 4 + ( params.count * Math.PI / 12 )
				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )

			when "Transporter"
				dx = 60 * params.count * params.scale
				
				if params.placement is 1					
					alpha = Math.PI - Math.asin( dx / params.r )
				else				
					alpha = 0 + Math.asin( dx / params.r )

				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )

			when "DNA"
				x = params.cx + ( params.count % 3 * 40 )
				y = params.cy - params.r / 2 + ( Math.floor( params.count / 3 ) * 40 )

			when "Metabolism"
				x = params.cx + ( params.count % 2 * 80 )
				y = params.cy + params.r / 2 + ( Math.floor( params.count / 2 ) * 40 )

			when "Protein"
				x = params.cx + params.r / 2 + ( params.count % 3 * 40 )
				y = params.cy - params.r / 2 + ( Math.floor( params.count / 3 ) * 40 )
				
			when "Substrate"
				x = ( params.cx + params.placement * 200 )
				x = ( params.cx - params.r - 130 ) if params.placement is -1
				x = ( params.cx + params.r + 130 ) if params.placement is 1 
				y = params.cy + ( Math.round( params.count ) * 100 * params.scale )
				
		return { x: x, y: y }
	
	# Get the simulation data from the cell
	# 
	# @param duration [Integer] The duration of the simulation
	# @return [Array] An array of datapoints
	_getCellData: ( duration ) ->
		cell_run = @_cell.run(duration)
		results = cell_run.results
		mapping = cell_run.map

		dt = 0.1

		# Get the interpolation for a fixed timestep instead of the adaptive timestep
		# generated by the ODE. This should be fairly fast, since the values all 
		# already there ( ymid and f )
		interpolation = []
		for time in [ 0 .. duration ] by dt
			interpolation[ time ] = results.at time;

		datasets = {}
		# Draw all the substrates
		for key, value of mapping
			dataset = []
			# Push all the values, but round for float rounding errors
			for time in [ 0 .. duration ] by dt
				dataset.push( interpolation[ time ][ value ] ) 
			datasets[ key ] = dataset

		return datasets
	
	_getGraphPlacement: ( ) ->
		x = 100
		y = 100
		unless @_numGraphs is 0
			width = 300 * @_scale
			height = width * @_scale
			padding = 20 * @_scale
			x += 1.5 * width * (@_numGraphs % 2)
			y +=  (height + 30) * Math.floor(@_numGraphs / 2) 
		@_numGraphs++
		
		return {x: x, y: y}
		

	# Draw the graphs with the data from the datasets
	#
	# @param datasets [Array] An array of datasets
	_drawGraphs: ( datasets ) ->
		@_numGraphs = 0
		# Draw all the substrates
		for key, dataset of datasets
			if ( !@_graphs[ key ] )
				@_graphs[ key ] = new View.Graph(@_paper, key, @)

			@_graphs[key].addData(dataset)
			placement = @_getGraphPlacement()
			@_graphs[key].draw(placement.x, placement.y, @_scale)

	startSimulation: ( ) ->
		duration = 10
		container = $(".container")

		datasets = @_getCellData(duration)
		
		@_drawGraphs(datasets)
	
	simulate: ( ) ->
		
	stopSimulation: ( ) ->

	_drawRedLines: (x) ->
		for key, graph of @_graphs
			graph._drawRedLine(x)
			

(exports ? this).View.Cell = View.Cell
