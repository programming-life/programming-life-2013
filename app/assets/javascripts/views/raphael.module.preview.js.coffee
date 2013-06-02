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
