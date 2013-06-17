'use strict'
# The controller for the Module views
#
class Controller.DummyModule extends Controller.Base

	# Creates a new module controller
	#
	# @param parent [Controller.Cell] the cell controller this controller belongs to
	# @param _modulector [Function] the module to controll
	# @param _number [Integer]
	# @param _params [Object]
	#
	constructor: ( @_parent, @_modulector, @_number = -1, @_params = {} ) ->
		
		@_count = @_parent.model.numberOf @_modulector
		module = new @_modulector( _( @_params ).clone( true ) )
	
		super new View.DummyModule( @_parent.view.paper, @_parent.view, @_parent.model, module,  
			@_number is -1 or @_count < @_number, @_params )

		@_selected = off
		@_hovered = off

		@_createBindings()

		@getter
			model: -> @view.model

	# Create bindings for the buttons
	#
	_createBindings: () ->
		@_bind( 'view.module.select', @view, @_setSelect )
		@_bind( 'view.module.selected', @view, @_setSelected )
		@_bind( 'view.module.hovered', @view, @_setHovered )
		@_bind( 'view.undo.node.selected', @view, @_setSelected )
		
		@_bind( 'cell.module.added', @, @_onModuleAdd )
		@_bind( 'cell.module.removed', @, @_onModuleRemove )
		@_bind( 'cell.metabolite.added', @, @_onModuleAdd )		
		@_bind( 'cell.metabolite.removed', @, @_onModuleRemove )
		return this
		
	#
	#
	_setSelect: ( view, event, state = not @_selected ) =>
		if view is @view
			@_parent.view.removePreviews()
		
	# Runs when view is selected or deselected
	#
	# @param view [View.Module] the view selected
	# @param event [jQuery.Event] the event raised
	# @param state [Boolean] the selection state
	#
	_setSelected: ( view, event, state = not @_selected ) =>
		if view isnt @view and state
			state = off
					
		if state isnt @_selected
			@view.setSelected state
			@_selected = state
			
			if view is @view and state
				@view.model = new @_modulector( _( @_params ).clone( true ) )
				@_parent.beginCreate @view.model
				
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
		
	# On Module Added to the Cell
	#
	# @param cell [Model.Cell] the cell added to
	# @param module [Model.Module] the module added
	#
	_onModuleAdd : ( cell, module ) ->
		if cell is @_parent.model and module instanceof @_modulector 
			@_count += 1
			if @_number isnt -1 and @_number <= @_count
				if @view.visible
					@view.hide()
			else
				@view.setPosition()

	# On Module Removed from the Cell
	#
	# @param cell [Model.Cell] the cell removed from
	# @param module [Model.Module] the module removed
	#
	_onModuleRemove : ( cell, module ) ->
		if cell is @_parent.model and module instanceof @_modulector
			@_count -= 1
			if @_number > @_count
				unless @view.visible
					@view.show()
			else
				@view.setPosition()
