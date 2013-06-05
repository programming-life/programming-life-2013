# Displays the properties of a module in a neat HTML popover
#
class View.Notification extends View.HTMLPopOver

	# Constructs a new Notifications view.
	#
	# @param parent [View.Cell,View.Module] the accompanying view
	# @param model [any] the subject to display stuff for
	#
	constructor: ( parent, subject ) ->
		
		@_messages = {}
		
		super parent, parent.getFullType?() ? '', 'notification', 'top'
		
		@_visible = off
		@_onNotificate( @, subject, @display )
	
	# Displays a notification
	#
	# @param caller [Context] the caller that raised the notification
	# @param source [Context] the notification subject
	# @param identifier [String] the message identifier
	# @param type [Integer] the type of the message
	# @param message [String] the message
	# @param args [Array<any>] additional arguments
	#
	display: ( caller, source, identifier, type, message, args ) ->
		
		@_messages[ identifier ] = {
			source: source
			message: message
			type: type
			identifier: identifier
			args: args
			visible: on
			closable: on
		}
		
		@_filter? @_messages[ identifier ]
				
		if _( @_messages ).some( (message) -> message.visible )
			@draw()
			@setPosition()
			elem = $ @_elem 
			unless @_visible is on
				elem.hide() 
				@show()
		else if @_visible is on
			@hide()
	
	#
	#
	show: () ->
		elem = $ @_elem
		elem.fadeIn('fast')
		@_visible = on
		
	#
	#
	hide: () ->
		elem = $ @_elem
		elem.fadeOut('fast')
		@_visible = off
		@_messages = {}
	
	# Creates the body of the message
	#
	# @return [jQuery.Elem] the body element
	#
	_createBody: () ->
		body = super()
		
		if _( @_messages ).all( (message) -> !message.visible or message.closable )
			@_closeButton = $('<button class="close">&times;</button>')
			@_closeButton.on( 'click', _( @hide ).bind @ )
			body.append @_closeButton
			
		for identifier, message of @_messages when message.visible is on
			classname = '' #View.Notification.getAlertClassFromType( message.type )
			elem = $('<div class="' + classname + '">' + message.message + '</div>')
			body.append( elem )
		return body
		
	# Gets the alert class from a type
	#
	# @param type [Integer] the type of the message
	# @return [String] classname
	#
	@getAlertClassFromType: ( type ) ->

		switch type
			when View.Notification.Notification.Success
				return 'alert-success'
			when View.Notification.Notification.Error
				return 'alert-error'
			when View.Notification.Notification.Info
				return 'alert-info'
			else
				return 'alert-warning'