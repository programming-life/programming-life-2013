# Base class for views that use Raphael
#
# @concern Mixin.EventBindings
# @concern Mixin.Catcher
# @concern Mixin.DynamicProperties
# 
class View.RaphaelBase extends View.Collection
	
	@concern Mixin.EventBindings
	@concern Mixin.Catcher
	@concern Mixin.DynamicProperties

	# Constructs a new Base view
	# 
	# @param _paper [Object] The paper to draw on
	#
	constructor: ( @_paper, @_parent = null ) ->
		super()
		
		@_contents = @_paper?.set()		
		@_allowEventBindings()

		@setter
			x: ( x ) ->
				@moveTo(x, @y, off)
			y: ( y ) ->
				@moveTo(@x, y, off)

		@getter
			x: ( ) ->
				return @_anchor?.getBBox()?.cx ? 0
			y: ( ) ->
				return @_anchor?.getBBox()?.cy ? 0
			paper: ( ) -> 
				return @_paper
	
	# Catcher function for Mixin.Catcher that will notificate any thrown Error on catchable methods
	#
	# @param e [Error] the error to notificate
	#
	_catcher: ( source, e ) =>
		text = if _( e ).isObject() then e.message ? 'no message' else e 
		@_notificate( @, source, _( 'catched-' ).uniqueId() , text, [], View.RaphaelBase.Notification.Error)

		
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

		super()		

		return @_contents
	
	# Redraw this view and it's children with their current parameters
	# 
	redraw: ( ) ->
		return @draw( @x, @y )

	# Add a css class to all content elements
	#
	# @param className [String] the css class to add
	# @param contents [Raphael] the contents to which to apply the class
	#
	_addClass: ( className, contents = @_contents ) ->
		if contents.constructor.prototype is Raphael.el
			$(contents.node).addClass(className)

		else if contents.constructor.prototype is Raphael.st
			contents.forEach ( elem ) =>
				@_addClass(className, elem)

	# Remove a css class to all content elements
	#
	# @param className [String] the css class to remove
	# @param contents [Raphael] the contents from which to remove the class
	#
	_removeClass: ( className, contents = @_contents ) ->
		if contents.constructor.prototype is Raphael.el
			$(contents.node).removeClass(className)

		else if contents.constructor.prototype is Raphael.st
			contents.forEach ( elem ) =>
				@_removeClass(className, elem)


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
