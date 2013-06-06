# Displays the notifications of a module in a neat HTML popover
#
class View.MainNotification extends View.Notification

	# Constructs a new MainNotification view.
	#
	# @param parent [View.Main] the accompanying view
	# @param subject [Model.*] the cell for which to display its notifications
	# @param params [Object] options
	#
	constructor: ( parent, subject, params = {} ) ->
		super parent, subject
		
	# Filters incoming messages
	#
	_filter: ( message ) ->
		if message.identifier isnt 'solution'
			message.visible = off
							
	# Create footer content and append to footer
	#
	# @param onclick [Function] the function to yield on click
	# @param saveText [String] the text on the save button
	# @return [Array<jQuery.Elem>] the footer and the button element
	#
	_createFooter: ( ) ->
		@_footer = $('<div class="modal-footer"></div>')
		@_footer.append @_button
		return [ @_footer, @_button ]						
					
	#
	#
	setSolutionMessage: ( message, @_button ) ->
		@display( @, @, 'solution', View.Main.Notification.Info, message, [] )
		#@display( @, @, 'solution-action', View.Main.Notification.Info, button, [] )
