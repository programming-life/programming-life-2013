'use strict'
# The controller for the Module views
#
class Controller.Module extends Controller.Base

	# Creates a new module controller
	#
	# @param parent [Controller.Cell] the cell controller this controller belongs to
	# @param model [Model.Module] the module to controll
	# @param _preview [Boolean] is this a preview module
	# @param _interaction [Boolean] has this interaction enabled
	#
	constructor: ( parent, @model, @_preview = off, @_interaction = on ) ->
		super new View.Module( parent.view.paper, parent.view, parent.model, @model, @_preview, @_interaction )
		
		@_selected = off
		@_hovered = off

		@_createBindings()

		@getter
			model: -> @view.model
			
	# Create bindings for the buttons
	#
	_createBindings: () ->
		@_bind( 'view.module.clicked', @view, @_setSelected )
		@_bind( 'view.module.hovered', @view, @_setHovered )
		
	# On action button clicked
	# 
	# @param event [jQuery.Event] the event thrown
	#
	_onAction: ( event ) =>
	
		console.log 'hi'
		action = event.target.data( 'action' )
		action = action.charAt(0).toUpperCase() + action.slice(1)
		
		func = @["_on#{action}"]
		func( event ) if func?
		
		@_actionAlways event
		
	#
	#
	_onComplete: ( event ) =>
		if @_preview
			parent.model.add @model
			@_preview = false
			@view.setPreview off
		console.log 'completed'
	
	#
	#
	_onCancel: ( event ) =>
		if @_preview
			parent.remove this
		console.log 'cancelled'
		
	#
	#
	_actionAlways: ( event ) =>
		console.log 'always'
	
	#
	#
	_setSelected: ( view, event, state = not @_selected ) =>
		if view isnt @view and state
			state = off
			
		if @_selected isnt state
			@view.setSelected state
			@_selected = state
		
	#
	#
	_setHovered: ( view, event, state = not @_hovered ) =>
		if view isnt @view and state
			state = off
			
		if @_hovered isnt state
			@view.setHovered state
			@_hovered = state
