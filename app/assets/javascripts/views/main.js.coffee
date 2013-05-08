class View.Main

	# Creates a new Main view
	# @todo split main view into cell and main vie2
	# @todo dummy module inactivate if already in cell
	#
	constructor: ( ) ->
		@_views = []
		@_drawn = []
		@rect = []
		@text = []

		@paper = Raphael( 'paper', 0, 0 )
		@width = $( window ).width() - 20
		@height = $( window ).height() - 5 
		@setSize( @width, @height)
		
		@cell = new Model.Cell()
		
		@_views.push new View.DummyModule( @paper, @cell, new Model.DNA() )
		@_views.push new View.DummyModule( @paper, @cell, new Model.Lipid() )
		@_views.push new View.DummyModule( @paper, @cell, new Model.Substrate( { placement: -1, name: 's' } ), { name: 's_ext', inside_cell: off, is_product: off, amount: 1 } )
		@_views.push new View.DummyModule( @paper, @cell, Model.Transporter.int(), { direction: 1 } )
		@_views.push new View.DummyModule( @paper, @cell, new Model.Metabolism() )
		@_views.push new View.DummyModule( @paper, @cell, new Model.Protein() )
		@_views.push new View.DummyModule( @paper, @cell, Model.Transporter.ext(), { direction: -1 } )
		
		#@_views.push new View.DummyModule( @paper, @cell, new Model.Substrate( { placement: -.5, name: 's' } ), { name: 's_int', inside_cell: on, is_product: off, amount: 1 } )
		#@_views.push new View.DummyModule( @paper, @cell, new Model.Substrate( { placement: 1, name: 'p' } ), { name: 'p_ext', inside_cell: off, is_product: on, amount: 1 } )
		#@_views.push new View.DummyModule( @paper, @cell, new Model.Substrate( { placement: .5, name: 'p' } ), { name: 'p_int', inside_cell: on, is_product: on, amount: 1 } )
		
		if ( @cell? )
			for module in @cell._modules
				@onModuleAdd( @cell, module )
		
		@_views.push new View.Action( @paper, 'Run', {}, () =>
			try
				graphs = {}
				graph = {}

				container = $(".container")
				if ( @graphs? and @graphs != {} )
					graphs = @graphs

					for name, graph of @graphs
						for set in graph._datasets
							set.fill = "rgba(220,220,220,0.5)"
							set.stroke = "rgba(220,220,220,1)"

					graph = {
						stroke : "rgba( 240, 180, 180, .6 )"
						fill : "rgba( 240, 180, 180, .7 )"
					}


				@graphs = @cell.visualize( 10, container, { dt: .2, graphs : graphs, graph: graph } )

				$('html, body').animate(
					{ scrollTop: 
						$( '.graph' ).first().offset().top - 20
					}, 'slow')
			catch err
				console.log err
			
		)

		tree = new Model.UndoTree(new Model.Node("Root",null))
		tree.add("test")
		tree.undo()
		tree.add("test2")
#		for i in [1..3]
#			tree.add( "Test"+i )
#			tree.undo()
#			tree.add( "Test"+4 )
#			tree.add( "Test"+5 )
		@_views.push new View.Tree( tree, @paper )
		
		$( window ).on( 'resize', @resize )
		Model.EventManager.on( 'cell.add.module', @, @onModuleAdd )
		Model.EventManager.on( 'cell.add.substrate', @, @onModuleAdd )
		Model.EventManager.on( 'cell.remove.module', @, @onModuleRemove )
		
		@draw()
	
	# Sets the size of the cell
	#
	# @param width [Integer] The width
	# @param height [Integer] The height
	#
	setSize: (width, height ) ->
		@paper.setSize(width, height)

	# Resizes the cell to the window size
	#
	resize: ( ) =>
		@width = $( window ).width() - 20
		@height = $( window ).height() - 5 
		@setSize( @width, @height )

		@draw()	
	
	# Draws the cell
	#
	draw: ( ) ->
	
		# First, determine the center and radius of our cell
		centerX = @width / 2
		centerY = @height / 2
		radius = Math.min( @width, @height ) / 2 * .7

		radius = 400 if radius > 400
		radius = 200 if radius < 200
		
		scale = radius / 400

		unless @_shape
			@_shape = @paper.circle( @x, @y, @radius )
			@_shape.node.setAttribute( 'class', 'cell' )
		else
			@_shape.attr
				cx: centerX
				cy: centerY
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
					cx: centerX
					cy: centerY
					r: radius
					scale: scale
				}
				
				placement = @getLocationForModule( view.module, params )
				
				counters[ "#{type}_#{direction}" ] = ++counter
				
			if ( view instanceof View.Action )
				placement = { x: centerX, y: centerY, scale }

			if ( view instanceof View.Tree )
				placement = {x: 200, y: 100, scale }
				
			
			view.draw( placement.x, placement.y, scale ) 
			
		

	# On module added, add it from the cell
	# 
	# @param cell [Model.Cell] cell added to
	# @param module [Model.Module] module added
	#
	onModuleAdd: ( cell, module ) =>
		unless cell isnt @cell
			unless _( @_drawn ).indexOf( module.id ) isnt -1
				@_drawn.unshift module.id
				@_views.unshift new View.Module( @paper, module )
				@draw()
			
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
			
			@draw()

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


(exports ? this).View.Main = View.Main
