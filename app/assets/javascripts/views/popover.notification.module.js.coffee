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
		
		@_bind( 'cell.module.added', @, ( cell ) => @hide() if cell is @_cell )
		@_bind( 'cell.module.removed', @, ( cell, module ) => @kill().hide() if module is @_source )		
		@_bind( 'cell.metabolite.added', @, ( cell ) => @hide() if cell is @_cell )
		@_bind( 'cell.metabolite.removed', @, ( cell, module ) => @kill().hide() if module is @_source )		
		@_bind( 'cell.before.run', @, ( cell ) => @hide() if cell is @_cell )
		
	# Filters incoming messages
	#
	_filter: ( message ) ->
		message.message = message.message.replace(/#([^\., ]*)/g, "<sub>$1</sub>")
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
