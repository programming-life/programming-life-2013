# Spline preview class
#
class View.SplinePreview extends View.Spline

	# Creates a new spline
	# 
	# @param paper [Raphael.Paper] the raphael paper
	# @param parent [View.Cell] the cell view this dummy belongs to
	# @param _cell [Model.Cell] the cell model displayed in the parent
	# @param orig [View.Module] the origin of the spline
	# @param dest [View.Module] the destination of the spline
	# @param interaction [Boolean] wether to add interaction to the splines or not
	#
	constructor: ( paper, parent, cell, orig, dest, interaction ) ->
		super paper, parent, cell, orig, dest, interaction
	
	# Adds interaction to the spline
	#
	addInteraction: ( ) ->
		super()
		@_bind "module.preview.ended", @, @_onModulePreviewEnded

	draw: ( ) ->
		super()

		$(@_contents.node).addClass('spline-preview')
	
	# Gets called when module preview ends
	#
	_onModulePreviewEnded: ( preview ) ->
		#if preview.model is @orig.model or preview.model is @dest.model
			#@_die()
