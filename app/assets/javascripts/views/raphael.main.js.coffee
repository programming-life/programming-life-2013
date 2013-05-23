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

		cell = new Model.Cell()
		@_views.push  new View.Cell( @_paper, cell)
		@_leftPane = new View.Pane(View.Pane.LEFT_SIDE, false) 
		@_leftPane.addView( new View.Undo( @_leftPane._container , cell._tree ) )
		@_views.push @_leftPane
		@_rightPane = new View.Pane(View.Pane.RIGHT_SIDE)
		#@_rightPane.addView( new View.Tree( @_rightPane._paper, cell._tree ) )
		@_views.push @_rightPane

		@resize()
		$( window ).on( 'resize', @resize )

		@_bind( 'view.cell.set', @, (cell) => @setTree(cell._tree) )

		@draw()

	# Resizes the cell to the window size
	#
	resize: ( ) =>
		old = @_width

		@_width = $( window ).width() - 20
		@_height = $( window ).height() - 5 
		@_paper.setSize( @_width, @_height )

		scale = (@_width - old) / old

		super( scale )
		@draw()

		Model.EventManager.trigger( 'paper.resize', @_paper )

	# Draws the main view
	#
	draw: ( ) ->
		centerX = @_width / 2
		centerY = @_height / 2
		radius = Math.min( @_width, @_height ) / 2 * .7

		radius = 400 if radius > 400
		radius = 200 if radius < 200
		
		scale = radius / 400

		for view in @_views
			switch view.constructor.name
				when "Cell"
					view.draw(centerX, centerY, scale)
				else
					view.draw()
	
	# Kills the main view
	#
	kill: ( ) ->
		super()
		@_paper.remove()
		$( window ).unbind()
	
	# Sets the tree of the view
	#
	# @param tree [Model.UndoTree] The tree
	#
	setTree:( tree ) ->
		@_tree = tree
		@draw()
