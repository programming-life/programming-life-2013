# A view class to display preview for a module
#
class View.ModulePreview extends View.Module
	
	# Creates a new module view
	#
	# @param paper [Raphael.Paper] the raphael paper
	# @param module [Model.Module] the module to show
	#
	constructor: ( paper, parent, @_cell, @model ) ->
		super paper, parent, @_cell, @model, off

	# Creates a new spline
	#
	# @param orig [View.Module] the origin module view
	# @param dest [View.Module] the destination module view
	# @return [View.Spline] the created spline
	#
	_createSpline: ( orig, dest ) ->
		if orig? and dest?
			return # Forgot to add spline preview class. Will remove this return when class added
			new View.SplinePreview(@paper, @_parent, @_cell, orig, dest)
