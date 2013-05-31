# The controller for the Undo view
#
# @concern Mixin.EventBindings
#
class Controller.Base extends Helper.Mixable

	@concern Mixin.EventBindings
	
	#
	#
	#
	#
	#
	constructor: ( @view ) ->
		@_children = []
		@_allowEventBindings()
		
	#
	#
	#
	#
	#
	addChild: ( controller ) ->
		@_children.push controller
		return this
			
	#
	#
	#
	#
	#
	#
	removeChild: ( controller, kill = on ) ->
		@_children = ( @_children ).without controller
		controller.kill() if kill
		return this
	
	#
	#
	#
	#
	kill: () ->
		removeChild( child, on ) for child in @_children
		@view.kill()
		return this