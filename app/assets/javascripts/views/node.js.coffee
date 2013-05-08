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

		padding = 30 * scale
		
		@_contents?.remove()
		@_contents = @_paper.set()

		@_drawText()

		@_radius = Math.max( @_text.getBBox().width, @_text.getBBox().height )

		@_drawCircle()
		@_drawShadow()


		@_contents.push(@_text, @_circle)

		scalar = (@_views.length - 1) * 0.5
		nextX = x - (2 * @_radius + padding) * scalar
		nextY = y + 2 * @_radius + padding

		for view in @_views
			view.draw(nextX, nextY, scale)
			@_contents.push view._contents...

			@_contents.push @_drawArrow(view)

			nextX = nextX + (2 * @_radius) + padding

		@_drawHitBox()


	
	_drawCircle: ( ) ->
		@_circle?.remove()
		@_circle = @_paper.circle(@_x, @_y, @_radius)
	
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
		@_hitBox.click =>
			@onClick()
		drag = ( dx, dy, x, y )  =>
			@_x = x
			@_y = y
			@_drawCircle( )
			@_drawShadow()
			@_drawText()
			@_drawHitBox()
		dragStart = () =>
			@_dragging = true
		dragStop= () =>
			@_dragging = false
			@_drawHitBox()

		@_hitBox.drag(drag, dragStart, dragStop)
	
	# Draw an arrow from this node to next
	# @param next [View.Node] The next node
	# @return [Object] The arrow
	# @todo Use angle and (co)sine
	_drawArrow:( next ) ->
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
	
	_clear: ( ) ->

(exports ? this).View.Node = View.Node
