class View.Main
	constructor: ( ) ->
		@_views = []		

		@paper = Raphael('paper', 0, 0)
		@resize()
		
		$(window).on('resize', @resize)
		$(document).on('moduleInit', @moduleInit)

		@draw()

	resize: ( ) =>
		@width = $(window).width() - 20
		@height = $(window).height() - 5 


		@paper.setSize(@width, @height)

		@draw()
		

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

		# Draw each module
		for view in @_views

			x = 0
			y = 0			

			switch view.module.constructor.name
				when "Lipid"
					alpha = -3 * Math.PI / 4
					x = centerX + radius * Math.cos(alpha)
					y = centerY + radius * Math.sin(alpha)

				when "Transporter"
					if view.module.direction is 1
						dx = 50 * inTransporters * scale					
						alpha = Math.PI - Math.asin(dx / radius)
						inTransporters++
					else
						dx = 50 * outTransporters * scale				
						alpha = 0 + Math.asin(dx / radius)
						outTransporters++

					x = centerX + radius * Math.cos(alpha)
					y = centerY + radius * Math.sin(alpha)

				when "DNA"
					x = centerX
					y = centerY - radius / 2

				when "Metabolism"
					x = centerX
					y = centerY + radius / 2

				when "Protein"
					x = centerX + radius / 2
					y = centerY - radius / 2

			view.draw(x, y, scale) 

	moduleInit: ( event, module ) =>
		unless module instanceof Model.CellGrowth
			view = new View.Module(module)
			@_views.push(view)
			@draw()

	getLocationForModule: ( module ) ->
		







(exports ? this).View.Main = View.Main