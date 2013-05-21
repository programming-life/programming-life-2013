# Displays the notifications of a module in a neat HTML popover
#
class View.ModuleNotification extends View.Notification

	# Constructs a new ModuleProperties view.
	#
	# @param parent [View.Module] the accompanying module view
	# @param module [Model.Module] the module for which to display its notifications
	# @param cellView [View.Cell] the accompanying cell view
	# @param cell [Model.Cell] the parent cell of the module
	# @param params [Object] options
	#
	constructor: ( parent, cellView, cell, module, params = {} ) ->
		@_cellView = cellView
		@_cell = cell
		
		super parent, module
		
		@_bind( 'cell.remove.module', @, ( cell, module ) => @kill().hide() if module is @_source )
		@_bind( 'cell.add.module', @, ( cell ) => @hide() if cell is @_cell )
		@_bind( 'cell.add.metabolite', @, ( cell ) => @hide() if cell is @_cell )
		@_bind( 'cell.before.run', @, ( cell ) => @hide() if cell is @_cell )
		
	#
	#
	_filter: ( message ) ->

		if message.identifier.indexOf('save') isnt -1 or message.identifier.indexOf('load') isnt -1
			message.closable = off
			
			if message.type is View.ModuleNotification.Notification.Info
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
			else
				message.visible = off
		
		console.log message
