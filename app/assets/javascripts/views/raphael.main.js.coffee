# The main view is the view used on the main page. It shows
# A cell and allows interaction on this cell.
#
class View.Main extends View.RaphaelBase

	# Creates a new Main view
	#
	# @todo dummy module inactivate if already in cell
	# @param container [String, Object] A string with an id or a DOM node to serve as a container for the view
	#
	constructor: ( container = "#paper" ) ->
	
		container = $( container )[0]
		super Raphael(container, 0,0) 

		@_viewbox = @_paper.setViewBox(-750, -500, 1500, 1000)
		
		@_createCellView()
		@_createUndoView()
		@_createConfirmReset()
		@_createLoadModal()
		
		@resize()
		@_createBindings()
		@draw()
	
	# Creates a new cell view
	#
	_createCellView: () ->
		@cell = new View.Cell( @_paper, @, new Model.Cell() )
		@_views.push @cell
	
	# Creates an undo view
	# 
	_createUndoView: () ->
		@_leftPane = new View.Pane(View.Pane.Position.Left, false) 
		@undo = new View.Undo( @cell.model.timemachine )
		@_leftPane.addView( @undo )
		@_views.push @_leftPane
		
	# Creates the confirmation for reset modal
	#
	_createConfirmReset: () ->
		@_resetModal = new View.ConfirmModal( 
			'Reset Confirmation',
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
		
		@_bind( 'view.cell.set', @, 
			(cell) => @undo.setTree( cell.model.timemachine ) 
		)
		@_bind( 'module.selected.changed', @, 
			(module, selected) => 
				@undo.setTree if selected then module.timemachine else @cell.model.timemachine 
		)
		
	# Toggles the simulation
	#
	# @param action [Boolean] start simulation
	#
	toggleSimulation: ( action ) ->
	
		if action
			return @cell.startSimulation( 25, 0, 50 )
			
		@cell.stopSimulation()
		return this
		
	# Resizes the cell to the window size
	#
	resize: ( ) =>	
		width = $( window ).width()
		height = $( window ).height() - 110

		edge = Math.min(width / 1.5, height)
		@_paper.setSize( edge * 1.5, edge )

		@_trigger( 'paper.resize', @_paper )

	# Draws the main view
	#
	draw: ( ) ->
		if @_locked
			@_drawWhenUnlocked = true
			return

		for view in @_views
			view.draw()

	# Returns the absolute (document) coordinates of a point within the paper
	#
	# @param x [float] the x position of the paper point
	# @param y [float] the y position of the paper point
	# @return [[float, float]] a tuple of the document x and y coordinates, respectively
	#
	getAbsoluteCoords: ( x, y ) ->
		width = @_viewbox.width
		height = @_viewbox.height
		offset = $(@_paper.canvas).offset()

		vX = @_viewbox._viewBox[0]
		vY = @_viewbox._viewBox[1]

		vWidth = @_viewbox._viewBox[2]
		vHeight = @_viewbox._viewBox[3]

		absX = offset.left + ((x - vX) / vWidth) * width
		absY = offset.top + ((y - vY) / vHeight) * height

		return [absX, absY]
		
	# Clears this view
	#
	clear: () ->
		super()
		@_resetModal.clear()
		@_loadModal.clear()
	
	# Kills the main view
	#
	kill: ( ) ->
		super()
		@_paper.remove()
		@_resetModal.kill()
		@_loadModal.kill()
		$( window ).off( 'resize' )
		
	# Loads a new cell into the cell view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback ) ->
		return @cell.load cell_id, callback
		
	# Saves the cell view model
	#
	# @return [jQuery.Promise] the promise
	#
	save: ( name ) ->
		return @cell.save( name )
		
	# Call confirmation for reset
	#
	# @param confirm [Function] action on confirmed
	# @param close [Function] action on closed
	# @param always [Function] action always
	#
	confirmReset: ( confirm, close, always ) ->
	
		func = ( caller, action ) =>
			confirm?() if action is 'confirm'
			close?() if action is 'close' or action is undefined
			always?()
			@_resetModal.offClosed( @, close ) 
			
		@_resetModal.onClosed( @, func )
		@_resetModal.show()
		
	# Call modal for load
	#
	# @param confirm [Function] action on confirmed
	# @param close [Function] action on closed
	# @param always [Function] action always
	#
	showLoad: ( load, close, always ) ->
	
		func = ( caller, action ) =>
			console.log action
			load?( @_loadModal.cell ) if action is 'load'
			close?() if action is 'cancel' or action is undefined
			always?()
			
			@_loadModal.offClosed( @, func ) 
			
		@_loadModal.onClosed( @, func )
		@_loadModal.show()
