# Displays the properties of a module in a neat HTML popover
#
class View.Notification extends View.HTMLPopOver

	# Constructs a new ModuleProperties view.
	#
	# @param parent [View.Cell,View.Module] the accompanying view
	# @param model [Model.Cell,Model.Module] the module for which to display its properties
	#
	constructor: ( parent, model ) ->
		
		@_source = model
		@_messages = {}
		
		super parent, model.constructor.name, 'notification', 'top'
		
		@_onNotificate( @, model, @display )
	
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
		}
		
		@_setSelected on
		
		@draw()
		@setPosition()
		
	hide: () ->
		@_setSelected off
		@_messages = {}
		
	# Nullifies the header
	#
	_createHeader: () ->	
		return [ undefined ]
	
	# Creates the body of the message
	#
	# @return [jQuery.Elem] the body element
	#
	_createBody: () ->
		body = super
		@_closeButton = $('<button class="close">&times;</button>')
		@_closeButton.on( 'click', _( @hide ).bind @ )
		
		body.append @_closeButton
		for identifier, message of @_messages
			classname = '' #View.Notification.getAlertClassFromType( message.type )
			elem = $('<div class="' + classname + '">' + message.message + '</div>')
			body.append( elem )
		return body
		
	# Nullifies the footer
	#
	_createFooter: () ->
		return [ undefined ]
		
	# Gets the alert class from a type
	#
	# @param type [Integer] the type of the message
	# @return [String] classname
	#
	@getAlertClassFromType: ( type ) ->
		console.log type
		switch type
			when View.Notification.Notification.Success
				return 'alert-success'
			when View.Notification.Notification.Error
				return 'alert-error'
			when View.Notification.Notification.Info
				return 'alert-info'
			else
				return 'alert-warning'
				
(exports ? this).View.Notification = View.Notification