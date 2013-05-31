# The controller for the Cell view
#
class Controller.Cell extends Helper.Mixable

	@concern Mixin.EventBindings

	# Creates a new instance of Main
	#
	# @param container [String, Object] A string with an id or a DOM node to serve as a container for the view
	#
	constructor: ( @_parentview, @model, @view ) ->
		@view = new View.Cell ( @_parentview? @_parentview?._paper, @_parentview, @model ? new Model.Cell() ) unless @view?
		
		@_children = []