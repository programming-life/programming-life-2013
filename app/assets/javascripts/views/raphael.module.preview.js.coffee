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
		return unless orig? and dest?
		new View.SplinePreview(@paper, @_parent, @_cell, orig, dest)

	#
	#
	draw: ( x = null, y = null ) ->
		super(x, y)
		
		$(@_box.node).addClass('module-preview')
		@_shadow.forEach( (line) => $(line.node).addClass('module-preview'))
