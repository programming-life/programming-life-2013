# The main view is the view used on the main page. It shows
# A cell and allows interaction on this cell.
#
class View.Main

	# Creates a new Main view
	# @todo dummy module inactivate if already in cell
	#
	constructor: ( ) ->
		@_paper = Raphael( 'paper', 0, 0 )
		@_cell = new View.Cell(@_paper, new Model.Cell())

		@resize()
		$( window ).on( 'resize', @resize )


	# Resizes the cell to the window size
	#
	resize: ( ) =>
		@_width = $( window ).width() - 20
		@_height = $( window ).height() - 5 
		@_paper.setSize( @_width, @_height )
		@draw()

	# Draws the main view
	#
	draw: ( ) ->
		centerX = @_width / 2
		centerY = @_height / 2
		radius = Math.min( @_width, @_height ) / 2 * .7

		radius = 400 if radius > 400
		radius = 200 if radius < 200
		
		scale = radius / 400

		@_cell.draw(centerX, centerY, scale)


(exports ? this).View.Main = View.Main