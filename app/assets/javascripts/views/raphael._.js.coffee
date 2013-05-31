# Base class for views that use Raphael
# 
class View.RaphaelBase extends View.Collection
	
	@concern Mixin.EventBindings

	# Constructs a new Base view
	# 
	# @param _paper [Object] The paper to draw on
	#
	constructor: ( @_paper, @_parent = null ) ->
		super()
		
		@_contents = @_paper?.set()
		
		console.log @_contents
		
		@_allowEventBindings()

		Object.defineProperties(@, 
			x:
				get: ( ) ->
					x = @_anchor?.getBBox()?.cx
					unless x?
						x = 0
					return x

				set: ( x ) ->
					@moveTo(x, @y, off)
			y:
				get: ( ) ->
					y = @_anchor?.getBBox()?.cy
					unless y?
						y = 0
					return y

				set: ( y ) ->
					@moveTo(@x, y, off)
		)

		
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
		super()
			
	# Kills this view 
	#
	kill: ( ) ->
		super()
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
			dt = 500
			ease = 'ease-in-out'

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

		super()		

		return @_contents
	
	# Redraw this view and it's children with their current parameters
	# 
	redraw: ( ) ->
		return @draw( @x, @y )

	# Returns the absolute (document) coordinates of a point within the paper
	#
	# @param x [float] the x position of the paper point
	# @param y [float] the y position of the paper point
	# @return [[float, float]] a tuple of the document x and y coordinates, respectively
	#
	getAbsoluteCoords: ( x, y ) ->
		return @_parent.getAbsoluteCoords(x, y)
