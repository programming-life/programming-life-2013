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
			
	# Kill the controller
	#
	kill: () ->
		$( "##{ @view.id }-properties" ).off( 'click', "[data-action]" )
		$( "##{ @view.id }-button" ).off( 'click' )
		$( "##{ @view.id }-button" ).off( 'mouseenter' )
		$( "##{ @view.id }-button" ).off( 'mouseleave' )
		super()
	
	# Create bindings for the buttons
	#
	_createBindings: () ->
		console.log "##{ @view.id }-button"

		$( "##{ @view.id }-properties" ).on( 'click', "[data-action]", @_onAction )
		$( "##{ @view.id }-button" ).on( 'click', => console.log 'parseInt(str, radix)'; @_trigger( 'view.module.selected', @, @view, [ on ] ) )
		$( "##{ @view.id }-button" ).on( 'mouseenter', => @_trigger( 'view.module.hovered', @, @view, [ on ] ) )
		$( "##{ @view.id }-button" ).on( 'mouseleave', => @_trigger( 'view.module.hovered', @, @view, [ off ] ) )
		
		@_bind( 'view.module.hovered', @, @view, @_setHovered )
		@_bind( 'view.module.selected', @, @view, @_setSelected )
		
	# On action button clicked
	# 
	# @param event [jQuery.Event] the event thrown
	#
	_onAction: ( event ) =>
	
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
	_setSelected: ( view, state ) =>
		console.log 'yolo'
		if view isnt @view and state
			state = off
			
		if @_selected isnt state
			@view.setSelected state
			@_selected = state
		
	#
	#
	_setHovered: ( view, state ) =>
		if view isnt @view and state
			state = off
			
		if @_hovered isnt state
			@view.setHovered state
			@_hovered = state
