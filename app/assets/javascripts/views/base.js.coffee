# Base class for views
# 
class View.Base extends Helper.Mixable
	
	@concern Mixin.EventBindings

	# Constructs a new Base view
	# 
	# @param paper [Object] The paper to draw on
	constructor: ( @_paper = null ) ->
		@_contents = @_paper?.set()
		@_views = []

		@_allowEventBindings()
	
	# Clear the contents of this view and it's children
	# 
	clear: ( ) ->
		@_contents?.remove()

		for view in @_views
			view.clear()

	# Draw this view and it's children
	# 
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	# @retuns [Object] The contents drawn
	#
	draw: ( @_x, @_y) ->
		@clear()

		for view in @_views
			placement = @_getViewPlacement( view )
			@_contents.push view.draw( placement.x, placement.y, 1)

		return @_contents
	
	# Redraw this view and it's children with their current parameters
	# 
	redraw: ( ) ->
		@draw(@_x, @_y)

		for view in @_views
			view.redraw()

	# Add a view to draw in the container
	#
	# @param view [View.Base] The view to draw
	addView: ( view ) ->
		@_views.push( view )
		placement = @_getViewPlacement( view )
		@_contents.push view.draw( placement.x, placement.y, 1)
	
	# Removes a view from the container
	#
	# @param [View.Base] The view to remove
	removeView: ( ) ->
		@_views = _( @_views ).without view
		@redraw()

	# Resize this view and it's children
	# 
	# @param scale [Float] The scale of the view
	#
	resize: ( scale = @_scale ) ->
		@_contents?.transform("S"+scale)

		for view in @_views
			view.resize( scale )

	# Kill this view and it's children, removing and unsetting all references from this view and it's children
	# 
	kill: ( ) ->
		@clear()
		@_contents = null
		
		@_unbindAll()

		for view in @_views
			view.kill()

(exports ? this).View.Base = View.Base
