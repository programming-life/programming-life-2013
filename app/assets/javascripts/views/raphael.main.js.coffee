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
	
	# Creates event bindings for the view
	#
	_createBindings: () ->
		$( window ).on( 'resize', => _( @resize() ).debounce( 300 ) )
		
		@_bind( 'view.cell.set', @, 
			(cell) => @undo.setTree( cell.model.timemachine ) 
		)
		@_bind( 'module.set.selected', @, 
			(module, selected) => 
				@undo.setTree if selected then module.timemachine else @cell.model.timemachine 
		)
		
	# Toggles the simulation
	#
	# @param action [Boolean] start simulation
	#
	toggleSimulation: ( action ) ->
		@cell.startSimulation( 20, 100 ) if action
		@cell.stopSimulation() unless action
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
	
	# Kills the main view
	#
	kill: ( ) ->
		super()
		@_paper.remove()
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
