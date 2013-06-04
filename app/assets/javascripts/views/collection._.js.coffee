class View.Collection extends Helper.Mixable

	# Creates a collection of views
	#
	constructor: () ->
		@_views = []
	
	# Clears the collection
	#
	clear: () ->
		view.clear() for view in @_views
		return this
	
	# Kills the collection
	#
	kill: () ->
		@clear()
		view.kill?() for view in @_views
		return this
		
	# Add a view to draw
	#
	# @param view [View.*] the view to add
	#
	add: ( view, draw = on ) ->
		@_views.push view
		view.draw() if draw
		return this
		
	# Removes the view
	#
	# @param view [View.*] the view to remove
	#
	remove: ( view ) ->
		@_views = _( @_views ).without view
		return this
		
	# Draw ths collection
	#
	draw: () ->
		view.draw() for view in @_views	
		return this
		
	# Redraws this collection
	#
	redraw: () ->
		view.redraw() for view in @_views
		return this
		
	#
	#
	each: ( func ) ->
		_( @_views ).each func
