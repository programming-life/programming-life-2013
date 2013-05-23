# Displays the notifications of a module in a neat HTML popover
#
class View.CellNotification extends View.Notification

	# Constructs a new CellNotification view.
	#
	# @param parent [View.Cell] the accompanying cell view
	# @param cell [Model.Cell] the cell for which to display its notifications
	# @param params [Object] options
	#
	constructor: ( parent, cell, params = {} ) ->
		super parent, cell
		
	# Filters incoming messages
	#
	_filter: ( message ) ->

		if message.identifier.indexOf('save') isnt -1 or message.identifier.indexOf('load') isnt -1
			message.closable = off
			
			if message.type is View.CellNotification.Notification.Info
				message.message = '
					<div class="loading active">
						<div class="spinner">
							<div class="mask">
								<div class="maskedCircle"></div>
							</div>
						</div>
					</div>
					<small>' + message.message + '</small>
					'