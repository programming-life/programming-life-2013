class View.Node
	constructor: ( node, paper, parent ) ->
		@_node = node
		@_paper = paper
		@_parent = parent

		@_views = []

		for child in @_node._children
			@_views.push new View.Node( child, @_paper, @ )
	
	# Performs the desired action on click
	#
	onClick: ( ) ->
		console.log("Clicked " + @_node._object)

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

		@_padding = 30 * @_scale

		@_contents?.remove()
		@_contents = @_paper.set()

		@_drawText()
		@_radius = Math.max( @_text.getBBox().width, @_text.getBBox().height ) * scale


		@_drawCircle()
		@_drawShadow()
		@_drawHitBox()

		unless @_parent is null
			@_drawArrow(@_parent)

		@_drawViews()


	_drawViews: ( ) ->
		scalar = (@_views.length - 1) * 0.5
		nextX = @_x - (2 * @_radius + @_padding) * scalar
		nextY = @_y + 2 * @_radius + @_padding

		for view in @_views
			view.draw(nextX, nextY, @_scale)
			@_contents.push view._contents...


			nextX = nextX + (2 * @_radius) + @_padding

	
	_drawCircle: ( ) ->
		@_circle?.remove()
		@_circle = @_paper.circle(@_x, @_y, @_radius)
		@_contents.push(@_text, @_circle)
	
	_drawShadow: ( ) ->
		@_shadow?.remove()
		@_shadow = @_circle?.glow
			width: 5
			opacity: .125
		@_shadow?.scale(.9, .9)
		
	
	_drawText: ( ) ->
		@_text?.remove()
		id = new Date() - @_node._creation + "\n"
		id += @_node._object

		@_text = @_paper.text(@_x, @_y, id)
		@_text.attr
			'font-size': 20 * @_scale
	
	_drawHitBox: ( ) ->
		unless @_dragging
			@_hitBox?.remove()
		@_hitBox = @_paper.circle(@_x, @_y, @_radius)
		@_hitBox.node.setAttribute(	"class","node-hitbox")
		drag = ( dx, dy, x, y )  =>
			@_x = x
			@_y = y
			@_drawCircle( )
			@_drawShadow()
			@_drawText()
			@_drawHitBox()

			unless @_parent is null
				@_drawArrow(@_parent)

			for view in @_views
				view._drawArrow(@)

		dragStart = () =>
			@_dragging = true
		dragStop= () =>
			@_dragging = false
			@_drawHitBox()

		@_hitBox.drag(drag, dragStart, dragStop)
	
	# Draw an arrow from this node to other
	# @param next [View.Node] The other node
	# @return [Object] The arrow
	# @todo Use angle and (co)sine
	_drawArrow:( next ) ->
		@_arrow?.remove()
		x = @_x

		y = @_y - @_radius
		nextX = next._x
		nextY = next._y + @_radius
		
		@_arrow = @_paper.arrowSet(x, y, nextX, nextY, 5)
		@_arrow[0].attr({
			"fill" : "black"
		})

		@_contents.push @_arrow

(exports ? this).View.Node = View.Node
