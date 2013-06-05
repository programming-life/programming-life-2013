# The controller for the Undo view
#
# @concern Mixin.EventBindings
#
class Controller.Base extends Helper.Mixable

	@concern Mixin.EventBindings
	
	# Creates the controller
	#
	# @param view [View.*] the view
	#
	constructor: ( @view ) ->
		@_children = {}
		@_allowEventBindings()
		
	# Adds a child controller
	#
	# @param id [String] the id of the controller
	# @param controller [Controller.*] the controller
	# @return [self] the chainable self
	#
	addChild: ( id, controller ) ->
		@_children[ id ] = controller
		return this
			
	# Remove a child controller
	# 
	# @param id [String] the id of the controller to remove
	# @param kill [Boolean] kill on remove
	# @return [self] the chainable self
	#
	removeChild: ( id, kill = on ) ->
		@_children[ id ].kill() if kill
		delete @_children[ id ] 
		return this
		
	# Gets the controller with the id
	# 
	# @param id [String] the id to get
	# @return [Controller.*] the controller
	#
	controller: ( id ) ->
		return @_children[ id ]
		
	#
	#
	controllers: () ->
		return @_children
		
	# Kills the controler and all subsequent views
	#
	# @return [self] the chainable self
	#
	kill: () ->
		@removeChild( id, on ) for id, child of @_children
		@view.kill()
		@_unbindAll()
		return this
		
	# Runs when the user tries to unload the page
	#
	beforeUnload: () ->
		return undefined
		
	# Runs when the user has unloaded the page
	#
	onUnload: () ->
		return undefined