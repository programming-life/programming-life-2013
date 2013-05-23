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

		width = $( window ).width()
		height = $( window ).height()
		x = -width / 2
		y = -height / 2

		@_viewbox = @_paper.setViewBox(-750, -500, 1500, 1000)

		@_cell = new Model.Cell()
		@_cellView = new View.Cell( @_paper, @, @_cell)

		@_leftPane = new View.Pane(View.Pane.LEFT_SIDE, false) 
		undo = new View.Undo( @_leftPane._container, @_cell._tree )
		@_leftPane.addView( undo )

		@_rightPane = new View.Pane(View.Pane.RIGHT_SIDE)

		@_views.push @_cellView
		@_views.push @_leftPane
		@_views.push @_rightPane
	
		@resize()
		
		$( window ).on( 'resize', =>
			_( @resize() ).debounce( 300 )
		)
		
		@_bind( 'view.cell.set', @, (cell) => 
			undo.setTree(cell.cell._tree)
		)
		@_bind( 'module.set.hovered', @, (module, hovered, selected) => 
			if hovered
				undo.setTree(module._tree)
			else unless @_moduleSelected
				undo.setTree(@_cell._tree)
		)
		@_bind( 'module.set.selected', @, (module, selected) => 
			if selected
				@_moduleSelected = on
			else
				@_moduleSelected = off
				undo.setTree(@_cell._tree)
		)

		@draw()

	# Resizes the cell to the window size
	#
	resize: ( ) =>	
		width = $( window ).width()
		height = $( window ).height()

		edge = Math.min(width / 1.5, height)
		@_paper.setSize( edge * 1.5, edge )

		Model.EventManager.trigger( 'paper.resize', @_paper )

	# Draws the main view
	#
	draw: ( ) ->
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
		$( window ).unbind()
