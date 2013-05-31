# Base class for views that use Raphael
# 
class View.RaphaelBase extends Helper.Mixable
	
	@concern Mixin.EventBindings
	@concern Mixin.Catcher

	# Constructs a new Base view
	# 
	# @param _paper [Object] The paper to draw on
	# @param _withPaper [Boolean] if true, adds a paper set on contents
	#
	constructor: ( @_paper = null, @_parent = null, @_withPaper = on ) ->
		@visible = on

		@_contents = @_paper?.set() if @_withPaper
		@_views = []
	
		@_allowEventBindings()

		Object.defineProperties(@, 
			x:
				get: ( ) ->
					x = @_anchor?.getBBox()?.cx
					return x ? 0

				set: ( x ) ->
					@moveTo(x, @y, off)
			y:
				get: ( ) ->
					y = @_anchor?.getBBox()?.cy
					return y ? 0

				set: ( y ) ->
					@moveTo(@x, y, off)
		)

	# Catcher function for Mixin.Catcher that will notificate any thrown Error on catchable methods
	#
	# @param e [Error] the error to notificate
	#
	_catcher: ( e ) =>
		@_notificate(@, @, '', e.name, [], View.RaphaelBase.Notification.Error)

		
	# Gets the Bounding Box for this view
	# 
	# @return [Object] the bounding box
	#
	getBBox: ( ) -> 
		return @_contents?.getBBox() ? { x:0, y:0, x2:0, y2:0, width:0, height:0 }
	
	# Clear the contents of this view and it's children
	# 
	clear: ( ) ->
		@_contents?.remove()
		for view in @_views
			view.clear()
			
	# Kills this view 
	#
	kill: ( ) ->
		@clear()	
		for view in @_views
			view.kill?()
		@_unbindAll()

	# Sets the position of this view according to its parent's instructions
	#
	# @param animate [Boolean] wether or not to animate the move
	#
	setPosition: ( animate = on ) ->
		[x, y] = @_parent?.getViewPlacement(@) ? [null, null]

		if x? and y?
			@moveTo(x, y, animate)

		return this

	# Moves the view to a new position
	#
	# @param x [float] the x coordinate to which to move
	# @param y [float] the y coordinate to which to move
	# @param animate [Boolean] wether or not to animate the move
	#
	moveTo: ( x, y, animate = on ) ->
		dx = x - @x
		dy = y - @y

		@move(dx, dy, animate)

		return this

	# Moves the view to a new position
	#
	# @param dx [float] the amount to move in the x direction
	# @param dy [float] the amount to move in the y direction
	# @param animate [Boolean] wether or not to animate the move
	#
	move: (dx, dy, animate = on, moveViews = on) ->
		done = ( ) =>
			@_trigger( 'view.moved', @ )			

		@_contents.stop()

		transform = "...t#{dx},#{dy}"
		if animate
			dt = 900
			ease = 'elastic'

			@_trigger( 'view.moving', @, [dx, dy, dt, ease] )

			@_contents.animate Raphael.animation(
				transform: transform
			, dt, ease, _(done).once()
			)
				
		else
			@_contents.transform(transform)
			done()

		if moveViews
			view.move(dx, dy, animate) for view in @_views				

		return this

	# Draw this view and it's children
	# 
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	# @retuns [Object] The contents drawn
	#
	draw: ( x, y ) ->
		@clear()

		@_anchor = @_paper.circle(x, y, 0)
		@_contents.push(@_anchor)

		@drawView view for view in @_views			

		return @_contents
	
	# Redraw this view and it's children with their current parameters
	# 
	redraw: ( ) ->
		@draw( @x, @y )

	# Add a view to draw in the container
	#
	# @param view [View.Base] The view to add
	#
	addView: ( view ) ->
		@_views.push view
		@drawView view
		
	# Draws the view
	# @param view [View.Base] The view to draw
	#
	drawView: ( view ) ->
		view.draw()
	
	# Removes a view from the container
	#
	# @param [View.Base] The view to remove
	#
	removeView: ( ) ->
		@_views = _( @_views ).without view
		@redraw()

	# Returns the absolute (document) coordinates of a point within the paper
	#
	# @param x [float] the x position of the paper point
	# @param y [float] the y position of the paper point
	# @return [[float, float]] a tuple of the document x and y coordinates, respectively
	#
	getAbsoluteCoords: ( x, y ) ->
		coords = @_parent?.getAbsoluteCoords(x, y)
		return coords if coords?
		return [ x, y ] unless @_paper?
		offset = $(@_paper.canvas).offset()
		absX = offset.left + x
		absY = offset.top + y
		return [ absX, absY ]
