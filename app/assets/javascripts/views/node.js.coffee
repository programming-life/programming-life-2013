class View.Node
	constructor: ( node, paper ) ->
		@_node = node
		@_paper = paper

		@_views = []

		for child in @_node._children
			@_views.push new View.Node( child, @_paper )

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

		padding = 15 * scale
		
		@_contents?.remove()
		@_contents = @_paper.set()

		# Draw stuff
		id = new Date() - @_node._creation + "\n"
		id += @_node._object

		text = @_paper.text(x, y, id)
		text.attr
			'font-size': 20 * scale

		radius = Math.max( text.getBBox().width, text.getBBox().height )
		@_circle = @_paper.circle( x, y, radius)

		@_contents.push(text, @_circle)

		scalar = (@_views.length - 1) * 0.5

		leftX = x - (2 * radius + padding) * scalar
		nextX = leftX
		for view in @_views
			view.draw(nextX, y + 2 * radius + padding, scale)
			@_contents.push view._contents...
			nextX = nextX + (2 * radius) + padding

		# Draw shadow around module view
		@_shadow?.remove()
		@_shadow = @_circle?.glow
			width: 5
			opacity: .125
		@_shadow?.scale(.9, .9)

(exports ? this).View.Node = View.Node
