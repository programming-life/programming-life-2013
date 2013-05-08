class View.Node
	constructor: ( node, paper ) ->
		@_node = node
		@_paper = paper

		@_views = []

		for child in @_node._children
			@_views.push new View.Node( child, @_paper )
	
	# Performs the desired action on clik
	#
	onClick: ( ) ->
		console.log("Clicked" + this)

	# Draws the view and thus the model
	#
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	# @param scale [Integer] The scale
	#
	draw: ( x, y, scale ) ->
		@_x = x
		@_y = y
		@_scale = scale

		padding = 30 * scale
		
		@_contents?.remove()
		@_contents = @_paper.set()

		# Draw stuff
		id = new Date() - @_node._creation + "\n"
		id += @_node._object

		text = @_paper.text(x, y, id)
		text.attr
			'font-size': 20 * scale

		@_radius = Math.max( text.getBBox().width, text.getBBox().height )
		@_circle = @_paper.circle( x, y, @_radius)

		@_contents.push(text, @_circle)

		scalar = (@_views.length - 1) * 0.5
		nextX = x - (2 * @_radius + padding) * scalar
		nextY = y + 2 * @_radius + padding

		for view in @_views
			view.draw(nextX, nextY, scale)
			@_contents.push view._contents...

			@_contents.push @drawArrow(view)

			nextX = nextX + (2 * @_radius) + padding

		# Draw shadow around module view
		@_shadow?.remove()
		@_shadow = @_circle?.glow
			width: 5
			opacity: .125
		@_shadow?.scale(.9, .9)

		# Draw hitbox in front of node view to detect mouseclicks
		@_hitBox?.remove()
		@_hitBox = @_paper.circle(@_x, @_y, @_radius)
		@_hitBox.node.setAttribute(	"class","node-hitbox")
		@_hitBox.click =>
			@onClick()

		@_hitBox.toFront()

	
	# Draw an arrow from this node to next
	# @param next [View.Node] The next node
	# @return [Object] The arrow
	# @todo Use angle and (co)sine
	drawArrow:( next ) ->
		#angle = Raphael.angle(@_x, @_y, next._x, next._y)
		a = ({
			x: @_x
			y: @_y + @_radius
			nextX: next._x
			nextY: next._y - @_radius - 5
		})

		arrow = @_paper.arrowSet(a.x, a.y, a.nextX, a.nextY, 5)
		arrow[0].attr({
			"fill" : "black"
		})
		return arrow

(exports ? this).View.Node = View.Node
