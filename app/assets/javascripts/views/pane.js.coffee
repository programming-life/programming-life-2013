# View for extensible Pane
#
class View.Pane extends View.Base
	
	@LEFT_SIDE : "left"
	@RIGHT_SIDE : "right"

	# Creates a new Pane
	#
	# @param paper [Object] The paper to draw on
	# @param side [String] The side the pane needs to be on
	constructor: ( @_paper, @_side ) ->
		super(@_paper)

		@_width = 400
		@_height = $( window ).height()

		@_extended = off
		@_buttonWidth = 40

		@_buttonOptions = {
			stroke : "black"
			fill: "grey"
		}
		@_containerOptions = {
			stroke : "black"
			fill: "green"
		}
		
	# Draw the view
	#
	# @param side [String] The side the pane needs to be on
	draw: ( side = @_side ) ->
		super(x, y)

		[ x, y ] = @_getXY( side )

		@_contents.push @_drawContainer(x, y)
		@_contents.push @_drawButton(x, y)
	
	# Get the x and y for this view based on the side
	#
	# @param side [String] The side to base the coordinates on
	#
	_getXY: ( side = @_side ) ->
		switch side
			when View.Pane.LEFT_SIDE
				x = 0
			when View.Pane.RIGHT_SIDE
				x = $( window ).width()
		y = 0
		return [ x, y ]
	
	# Draw the container for the objects displayed in the pane
	#
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	_drawContainer: ( x, y ) ->
		container = @_paper.rect(x, y, x + @_width, y + @_height)
		container.attr( @_containerOptions )
		return container

	# Draw the button to extend or retract the pane
	#
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	_drawButton: ( x, y ) ->
		button = @_paper.rect(x, y, x + @_buttonWidth, y + @_height)
		button.attr( @_buttonOptions )
		return button
	
	_extend: ( ) ->

	_retract: ( ) ->

	# Set the button options
	#
	# @param options [Object] The new options
	setButtonOptions: ( options = {} ) ->
		@_buttonOptions = options
	
	# Set the container options
	#
	# @param options [Object] The new options
	setContainerOptions: ( options = {} ) ->
		@_containerOptions = options

(exports ? this).View.Pane = View.Pane
