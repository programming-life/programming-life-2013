class View.Main

	# Creates a new Main view
	#
	constructor: ( ) ->
		@_views = []		
		@_drawn = []

		@paper = Raphael('paper', 0, 0)
		@resize()
		
		$(window).on('resize', @resize)
		$(document).on('moduleInit', @moduleInit)

		@draw()

	# Resizes the cell to the window size
	#
	resize: ( ) =>
		@width = $(window).width() - 20
		@height = $(window).height() - 5 


		@paper.setSize(@width, @height)

		@draw()
		
	# Draws the cell
	#
	draw: ( ) ->
		# First, determine the center and radius of our cell
		centerX = @width / 2
		centerY = @height / 2
		radius = Math.min(@width, @height) / 2 * .7

		radius = 400 if radius > 400
		radius = 200 if radius < 200
		
		scale = radius / 400

		unless @_shape
			@_shape = @paper.circle(@x, @y, @radius)
			@_shape.node.setAttribute('class', 'cell')

		else
			@_shape.attr
				cx: centerX
				cy: centerY
				r: radius
				
		inTransporters = 0
		outTransporters = 0
		counters = {}
		
		# Draw each module
		for view in @_views
		
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
			view.draw( placement.x, placement.y, scale) 

	# On module initialization add it to the cell
	# 
	# @param event [Object] event raised
	# @param module [Model.Module] module added
	#
	moduleInit: ( event, module ) =>
		unless _(@_drawn).indexOf( module.name ) isnt -1
			@_drawn.push module.name
			view = new View.Module(module)
			@_views.push(view)
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
				dx = 50 * params.count * params.scale
				
				if params.placement is 1					
					alpha = Math.PI - Math.asin( dx / params.r )
				else				
					alpha = 0 + Math.asin( dx / params.r )

				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )

			when "DNA"
				x = params.cx + ( params.count % 3 * 40 )
				y = params.cy - params.r / 2 + ( Math.round( params.count / 3 ) * 40 )

			when "Metabolism"
				x = params.cx + ( params.count % 3 * 40 )
				y = params.cy + params.r / 2 + ( Math.round( params.count / 3 ) * 40 )

			when "Protein"
				x = params.cx + params.r / 2 + ( params.count % 3 * 40 )
				y = params.cy - params.r / 2 + ( Math.round( params.count / 3 ) * 40 )
				
			when "Substrate"
				x = ( params.cx + params.placement * 200 )
				x = ( params.cx - params.r - 130 ) if params.placement is -1
				x = ( params.cx + params.r + 130 ) if params.placement is 1 
				y = params.cy + ( Math.round( params.count ) * 100 * params.scale )
				
		return { x: x, y: y }


(exports ? this).View.Main = View.Main