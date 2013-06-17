# The main view is the view used on the main page. It shows
# A cell and allows interaction on this cell.
#
class View.Main extends View.RaphaelBase

	# Creates a new Main view
	#
	# @todo dummy module inactivate if already in cell
	# @param container [String, Object] A string with an id or a DOM node to serve as a container for the view
	#
	constructor: ( container = "#paper", @_target = window ) ->
	
		container = $( container )[0]
		super Raphael(container, 0,0) 

		@_viewbox = @paper.setViewBox(-750, -500, 1500, 1000)
		
		@_createSidebars()
		@_createConfirmReset()
		@_createLoadModal()
		@_createBindings()
		
		@resize()
		
		@draw()
		
	# Creates sidebars
	#
	_createSidebars: () ->
		@_leftPane = new View.Pane( View.Pane.Position.Left, false ) 
		@add @_leftPane, off
		
	# Creates the confirmation for reset modal
	# Creates the confirmation for reset modal
	#
	_createConfirmReset: () ->
		@_resetModal = new View.ConfirmModal( 
			'Confirm resetting the virtual cell',
			'Are you sure you want to reset the virtual cell?
			You will lose all unsaved changes and this action
			can not be undone.'
		)
		
	# Creates the load modal
	#
	_createLoadModal: () ->
		@_loadModal = new View.LoadModal()
	
	# Creates event bindings for the view
	#
	_createBindings: () ->
		$( window ).on( 'resize', => _( @resize() ).debounce( 100 ) )
		
	# Create action notifications
	#
	# @param [any] Subject model
	# @param [String] element to show over
	#
	_createActionNotifications: ( subject, element ) ->
		@_notifications?.kill()
		
		parent = 
			getAbsolutePoint: ( location ) ->
				offset = $( element ).offset()
				return [ offset.left + $( element ).width(), offset.top ]
					
		@_notifications = new View.MainNotification( parent, subject )
		
	# Adds a view to the left pane
	#
	addToLeftPane: ( view ) ->
		@_leftPane.addView view	
	
	# Resizes the cell to the target size
	#
	resize: ( ) =>	
		width = $( @_target ).width()
		height = $( @_target ).height() - 110

		edge = Math.min(width / 1.5, height)
		@paper.setSize( edge * 1.5, edge )

		@_trigger( 'paper.resize', @paper )

	# Draws the main view
	#
	draw: ( ) ->
		for view in @_views
			view.draw()

	# Returns the absolute (document) coordinates of a point within the paper
	#
	# @param x [float] the x position of the paper point
	# @param y [float] the y position of the paper point
	# @return [<float, float>] a tuple of the document x and y coordinates, respectively
	#
	getAbsoluteCoords: ( x, y ) ->
		width = @_viewbox.width
		height = @_viewbox.height
		offset = $(@paper.canvas).offset()

		vX = @_viewbox._viewBox[0]
		vY = @_viewbox._viewBox[1]

		vWidth = @_viewbox._viewBox[2]
		vHeight = @_viewbox._viewBox[3]

		absX = offset.left + ((x - vX) / vWidth) * width
		absY = offset.top + ((y - vY) / vHeight) * height

		return [absX, absY]
		
	# Clears this view
	#
	# @return [self] chainable self
	#
	clear: () ->
		super()
		@_resetModal?.clear()
		@_loadModal?.clear()
		@_optionsModal?.clear()
		@_notifications?.clear()
		return this
	
	# Kills the main view
	#
	# @return [self] chainable self
	#
	kill: ( ) ->
		super()
		@paper.remove()
		@_resetModal?.kill()
		@_loadModal?.kill()
		@_notifications?.kill()
		@_optionsModal?.kill()
		$( window ).off( 'resize' )
		$( '#actions' ).off( 'click', '[data-action]' )
		return this

	# Gets the cell name
	#
	# @return [String, null] the cell name
	#
	getCellName: () ->
		value = $( '#cell_name' ).val()
		return null if value.length is 0
		return value ? null
	
	# Sets the cell name
	#
	# @param name [String] the cell name
	# @return [self] chainable self
	#
	setCellName: ( name ) ->
		value = $( '#cell_name' ).val name
		return this
		
	# Gets the progress bar
	#
	# @return [jQuery.Elem] the progress bar
	#
	getProgressBar: () ->
		return $( '#progress' )
		
	# Sets the progress bar
	#
	# @param value [Float] range 0..1 percentage filled
	# @return [self] chainable self
	#
	setProgressBar: ( value ) ->
		@getProgressBar()
			.find( '.bar' )
			.css( 'width', "#{value * 100}%" )
		return this
		
	# Hides the progress bar
	#
	# @return [self] chainable self
	#
	hideProgressBar: ( ) ->
		@getProgressBar().css( 'opacity', 0 )
		return this
		
	# Shows the progress bar
	#
	# @return [self] chainable self
	#
	showProgressBar: () ->
		@getProgressBar().css( 'visibility', 'visible' )
		@getProgressBar().css( 'opacity', 1 )
		return this
		
	# Hides the panes
	#
	hidePanes:( ) ->
		@_leftPane.retract()
	
	# Binds an action on the action buttons
	#
	# @return [self] chainable self
	#
	bindActionButtonClick: ( action ) ->
		$( '#actions' ).off( 'click', '[data-action]' )
		$( '#actions' ).on( 'click', '[data-action]', action )
		@enableActionButtons()
		return this
		
	# Gets the action buttons
	#
	# @return [jQuery.Collection] the action button elements
	#
	getActionButtons: ( ) ->
		return $( '#actions' ).find( '[data-action], button.dropdown-toggle' )
		
	# Resets the action buttons visual state
	# 
	# @return [self] chainable self
	# 
	resetActionButtons: () ->
		@getActionButtons()
			.removeClass( 'btn-success' )
			.removeClass( 'btn-danger' )
			.prop( { 'disabled': true } )
			.filter( ':not([data-toggle])' )
				.filter( ':not([class*="btn-warning"])' )
				.find( 'i' )
					.removeClass( 'icon-white' )
		return this
		
	# Resets the action button button state
	#
	# @return [self] chainable self
	# 
	resetActionButtonState: () ->
		@getActionButtons()
			.button( 'reset' )
		return this
		
	# Enable the action buttons (undisable)
	#
	# @return [self] chainable self
	#
	enableActionButtons: () ->
		@getActionButtons()
			.prop( 'disabled', false )
		return this
			
	# Sets a button statr
	#
	# @param elem [jQuery.elem]
	# @param state [String] the button state
	# @param className [String] the class to add
	# @return [self] chainable self
	#
	setButtonState: ( elem, state, classname ) ->
		elem.button( state )
		elem.addClass( classname ) if classname?
		return this
		
	# Call confirmation for reset
	#
	# @param confirm [Function] action on confirmed
	# @param close [Function] action on closed
	# @param always [Function] action always
	# @return [self] chainable self
	#
	confirmReset: ( confirm, close, always ) ->
	
		func = ( caller, action ) =>
			confirm?() if action is 'confirm'
			close?() if action is 'close' or action is undefined
			always?()
			@_resetModal.offClosed( @, close ) 
			
		@_resetModal.onClosed( @, func )
		@_resetModal.show()
		return this
		
	# Call modal for load
	#
	# @param load [Function] action on confirmed
	# @param other [Function] action on confirmed but not load
	# @param close [Function] action on closed
	# @param always [Function] action always
	# @return [self] chainable self
	#
	showLoad: ( load, other, close, always ) ->
	
		func = ( caller, action ) =>
			if action is 'cancel' or action is undefined
				close?()
			else if action is 'load'
				load?( @_loadModal.cell ) 
			else
				other?( action, @_loadModal.cell )
			
			always?()
			
			@_loadModal.offClosed( @, func ) 
			
		@_loadModal.onClosed( @, func )
		@_loadModal.show()
		return this
			
	# On error, give alternative to resolve the error
	#
	setSolutionNotification: ( solution, action ) ->
		@_notifications.setSolutionMessage( solution, action )
		return this
		
	# Sets the notifications on
	# 
	# @param [any] the subject
	# @param [String] the element
	#
	setNotificationsOn: ( subject, element ) ->
		@_createActionNotifications( subject, element )
		#@_notifications.show()
