# Base class for views that use Raphael
# 
class View.RaphaelBase extends Helper.Mixable
	
	@concern Mixin.EventBindings

	# Constructs a new Base view
	# 
	# @param _paper [Object] The paper to draw on
	# @param _withPaper [Boolean] if true, adds a paper set on contents
	#
	constructor: ( @_paper = null, @_parent = null, @_withPaper = on ) ->
		@_contents = @_paper?.set() if @_withPaper
		@_views = []
	
		@_allowEventBindings()
		
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

	# Draw this view and it's children
	# 
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	# @retuns [Object] The contents drawn
	#
	draw: ( @x, @y ) ->
		@clear()

		for view in @_views
			@drawView view

		return @_contents
	
	# Redraw this view and it's children with their current parameters
	# 
	redraw: ( ) ->
		@draw( @x, @y )

		for view in @_views
			view.redraw()

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
		if view instanceof View.RaphaelBase
			placement = @_getViewPlacement( view )
			viewcontents = view.draw( placement.x, placement.y, 1)
			@_contents.push viewcontents
		else
			view.draw()
	
	# Removes a view from the container
	#
	# @param [View.Base] The view to remove
	#
	removeView: ( ) ->
		@_views = _( @_views ).without view
		@redraw()

	#
	#
	@_getViewPlacement: ( view ) ->
		return { x: 0, y:0, scale: 1 }

	# Returns the absolute (document) coordinates of a point within the paper
	#
	# @param x [float] the x position of the paper point
	# @param y [float] the y position of the paper point
	# @return [[float, float]] a tuple of the document x and y coordinates, respectively
	#
	getAbsoluteCoords: ( x, y ) ->
		return @_parent.getAbsoluteCoords(x, y)
