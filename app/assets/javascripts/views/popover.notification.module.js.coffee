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
		
		@_bind( 'cell.remove.module', @, ( cell, module ) => @kill() if module is @_source )
		@_bind( 'cell.add.module', @, ( cell ) => @hide() if cell is @_cell )
		@_bind( 'cell.add.metabolite', @, ( cell ) => @hide() if cell is @_cell )
		@_bind( 'cell.before.run', @, ( cell ) => @hide() if cell is @_cell )
