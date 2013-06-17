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
	constructor: ( @_parent, model, @_preview = off, @_interaction = on ) ->
		super new View.Module( @_parent.view.paper, @_parent.view, @_parent.model, model, @_preview, @_interaction )
		
		@_selected = @_preview
		@_hovered = off

		@_createBindings()

		@getter
			model: -> @view.model
	
	# Create bindings for the buttons
	#
	_createBindings: () ->
		@_bind( 'view.module.selected', @view, @_setSelected )
		@_bind( 'view.undo.node.selected', @view, @_setSelected )
		@_bind( 'view.module.hovered', @view, @_setHovered )
		@_bind( 'view.module.removed', @view, @_setRemoved )
		@_bind( 'view.module.saved', @view, @_setChanged )
		@_bind( 'view.module.changed', @view, @_previewChanged )
		return this
		
	# Runs when view activates save button
	#
	# @param view [View.Module] the view
	# @param changes [Object] the changes made
	#
	_setChanged: ( view, changes ) =>
		return this if view isnt @view
		@_parent.view.removePreviews()
		
		for key, value of changes
			@model[ key ] = value
			
		if @_preview
			@_parent.endCreate @model
			@_parent.model.add @model
			
		@_parent.automagicAdd @model, off
		return this
	
	# Runs when view activates a change
	#
	# @param view [View.Module] the view
	# @param params [Object] the parameters
	# @param key [String] the parameter changed
	# @param value [any] the new value
	# @param currents [Object] the current values
	#
	_previewChanged: ( view, params, key, value, currents ) =>
		return this if view isnt @view
		@_parent.view.removePreviews()

		module = new @model.constructor( _( _( params ).clone( true ) ).defaults( currents ) )
		@_parent.automagicAdd module, on
		@view.createSplines module, on
		return this
		
	# Runs when view is selected or deselected
	#
	# @param view [View.Module] the view selected
	# @param event [jQuery.Event] the event raised
	# @param state [Boolean] the selection state
	#
	_setSelected: ( view, event, state = not @_selected ) =>
		if state is off
			@_parent.view.removePreviews()
				
		if view is @view and state
			@_parent.automagicAdd @model, on
			@view.createSplines @model, on
				
		if view isnt @view and state
			state = off
			
		if @_selected isnt state
			@view.setSelected state
			@_selected = state
			@_parent.endCreate @model if @_preview and not state
			
		return this
		
	# Runs when view is hovered or dehovered
	#
	# @param view [View.Module] the view hovered
	# @param event [jQuery.Event] the event raised
	# @param state [Boolean] the hovered state
	#
	_setHovered: ( view, event, state = not @_hovered ) =>
		if view isnt @view and state
			state = off
			
		if @_hovered isnt state
			@view.setHovered state
			@_hovered = state
		return this

	# Runs when view activates delete button
	#
	# @param view [View.Module] the view
	#
	_setRemoved: ( view, event ) =>
		return this if view isnt @view
		@_parent.view.removePreviews()
		@_parent.model.remove @model
		return this
