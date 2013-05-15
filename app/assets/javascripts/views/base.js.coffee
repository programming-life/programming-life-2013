# Base class for views
# 
class View.Base extends Helper.Mixable
	
	@include Mixin.EventBindings

	# Constructs a new Base view
	# 
	# @param paper [Object] The paper to draw on
	constructor: ( @_paper ) ->
		@_contents = @_paper.set()

		@_allowBindings()
	
	# Clear the contents of this view
	# 
	clear: ( ) ->
		@_contents?.remove()

	# Draw this view
	# 
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	#
	draw: ( @_x, @_y) ->
		@clear()
	
	# Redraw this view with it's current parameters
	# 
	redraw: ( ) ->
		@draw(@_x, @_y)

	# Resize this view
	# 
	# @param scale [Float] The scale of the view
	#
	resize: ( @_scale ) ->

	# Kill this view, removing and unsetting all references from this view
	# 
	kill: ( ) ->
		@clear()
		@_contents = null

(exports ? this).View.Base = View.Base
