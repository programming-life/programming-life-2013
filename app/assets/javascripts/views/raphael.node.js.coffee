#
#
class View.Node extends View.RaphaelBase

	#
	#
	constructor: ( node, paper, parent ) ->
		super(paper)
		@_node = node
		@_parent = parent

		for child in @_node._children
			@_views.push new View.Node( child, @_paper, @ )

		Model.EventManager.on( 'node.creation', @, @_addNode)
	
	# Performs the desired action on click
	#
	onClick: ( ) ->

	# Draws the view and thus the model
	#
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	# @param scale [Integer] The scale
	#
	draw: ( x = @_x, y = @_y, scale = @_scale ) ->
		@clear()
		@_x = x
		@_y = y
		@_scale = scale

		@_padding = 10 * @_scale

		@_contents.push @_drawText()
		@_radius = Math.max( @_text.getBBox().width, @_text.getBBox().height ) * @_scale


		@_contents.push @_drawCircle()
		@_contents.push @_drawShadow()
		@_contents.push @_drawHitBox()

		unless @_parent is null
			@_contents.push @_drawArrow(@_parent)

		@_drawViews()
	
	# Adds a node view to the children of this node view
	#
	# @param node [Model.Node] The node to add the view of
	_addNode: ( node ) ->
		if node in @_node._children
			@_views.push new View.Node( node, @_paper, @ )
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
		return @_circle
	
	_drawShadow: ( ) ->
		@_shadow?.remove()
		@_shadow = @_circle?.glow
			width: 5
			opacity: .125
		@_shadow?.scale(.9, .9)
		return @_shadow
		
	
	_drawText: ( ) ->
		@_text?.remove()
		id = new Date() - @_node._creation + "\n"
		if @_node._object instanceof Model.Action
			id += @_node._object._description
		else
			id += "Cell creation"

		@_text = @_paper.text(@_x, @_y, id)
		@_text.attr
			'font-size': 16 * @_scale

		return @_text
		
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
		return @_hitBox
	
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

		return @_arrow
