# Displays the notifications of a module in a neat HTML popover
#
# @concern Mixin.DynamicProperties
#
class View.Tutorial extends View.HTMLPopOver

	@concern Mixin.DynamicProperties

	# Constructs a new Notifications view.
	#
	# @param parent [View.Cell,View.Module] the accompanying view
	# @param model [any] the subject to display stuff for
	#
	constructor: ( parent ) ->
		@messages = [ 'Nope. Start that tutorial first dude!' ]
		@_nextOnEvent = off
		@_visible = off
		super parent, 'Tutorial', 'tutorial', 'tutorial'
		elem = $ @_elem
		elem.hide()
		elem.css( 'opacity', 0 )
		
		@getter
			visible: () -> @_visible
		
	# Create the popover header
	#
	# @return [Array<jQuery.Elem>] the header and the button element
	#
	_createHeader: ( ) ->
		@_header = $('<div class="popover-title"></div>')

		@_hideButton = $('<button class="close" title="Minimize this window. Press the question mark at the bottom of this screen to show it again"><i class="icon-minus"></i></button>')
		@_hideButton.on('click', @hide )

		@_closeButton = $('<button class="close" title="Cancel the tutorial">&times;</button>')
		@_closeButton.on('click', @_cancel )
		
		@_header.append @title
		@_header.append @_closeButton
		@_header.append @_hideButton
		return [ @_header, @_hideButton, @_closeButton ]
		
	# Create the popover body
	#
	_createBody: () ->
		@_body = super
		@_drawContents()
		return @_body
		
	#  Create footer content and append to footer
	#
	# @param onclick [Function] the function to yield on click
	# @param saveText [String] the text on the save button
	# @return [Array<jQuery.Elem>] the footer and the button element
	#
	_createFooter: ( ) ->
		@_footer = $('<div class="modal-footer"></div>')

		@_cancelButton = $('<button class="btn pull-left" title="Stop the tutorial">' + '<i class="icon-remove"></i> Stop' + '</button>')
		@_cancelButton.on( 'click', @_cancel )

		@_backButton = $('<button class="btn" title="Go back to the previous step">' + '<i class="icon-chevron-left"></i> Back' + '</button>')
		@_backButton.on( 'click', @_back )
		
		@_nextButton = $('<button class="btn btn-primary" title="Advance to the next step">' + 'Next <i class="icon-chevron-right icon-white"></i>' + '</button>')
		@_nextButton.on( 'click', @_next )

		@_footer.append @_cancelButton 
		@_footer.append @_backButton
		@_footer.append @_nextButton unless @_nextOnEvent 
		return [ @_footer, @_cancelButton, @_backButton, @_nextButton ]
		
	# Draws the body of the popover
	#
	_drawContents: ( ) ->
		for message in @messages
			contents = $('<div>' + message + '</div>')
			@_body.append contents
		return contents
		
	# Shows the tutorial popover
	#
	show: ( callback, animate = 'top', amount = 10 ) =>
		elem = $ @_elem
		value = parseFloat( elem.css( animate ) )
		properties = {}
		properties[ 'opacity' ] = .92
		properties[ animate ] = value
		elem.css( 'display', 'block' )
		elem.css( animate, value + amount )
		elem.animate( properties, 200, () =>
			elem.css( animate, value )
			callback?()
		)
		@_visible = on
		
	# Hides the tutorial popover
	#
	hide: ( callback, animate = 'top', amount = 10 ) =>
		elem = $ @_elem
		value = parseFloat( elem.css( animate ) )
		properties = {}
		properties[ 'opacity' ] = 0
		properties[ animate ] = value + amount
		elem.animate( properties, 200, () => 
			elem.css( 'display', 'none' )
			elem.css( animate, value )
			callback?()
		)
		@_visible = off
		
	# Shows a message on this tutorial screen
	#
	# @param message [String] the next tutorial message
	# @param nextOnEvent [Boolean] if true, wait on event
	# @returns [self] chainable self
	#
	showMessage: ( title, messages, nextOnEvent = off, animate = 'left', amount = 10 ) ->
		@title = title
		@messages = messages
		
		@_nextOnEvent = nextOnEvent
		@draw()
		@setPosition()
		@show( undefined, animate, amount )
		return this
		
	# Progresses to the next event in the tutorial
	#
	_back: () =>
		return unless @_visible
		@hide( ( () => @_trigger( 'view.tutorial.back', @, [] ) ), 'left', -10 )

	# Progresses to the next event in the tutorial
	#
	_next: () =>
		return unless @_visible
		@hide( ( () => @_trigger( 'view.tutorial.next', @, [] ) ), 'left' )

	# Cancels the tutorial sequence until it is started again
	#
	_cancel: () =>
		return unless @_visible
		@_trigger( 'view.tutorial.cancel', @, [] ) 
		@hide( )
		
	# Sets the position of the popover so the arrow points straight at the model view
	#
	setPosition: ( ) ->

		if not @_parent.getAbsolutePoint?
			throw new TypeError( "Expected parent [#{@_parent?.constructor.name ? @_parent}] to have the getAbsolutePoint function." )
		
		[x, y] = @_parent.getAbsolutePoint(@_location)
		
		width = @_elem.width()
		height = @_elem.height()

		top = y
		left = x - width
		@_elem.css( { left: left, top: top } )
		return this