# View for extensible Pane
#
class View.Pane extends View.Base
	
	@LEFT_SIDE : "left"
	@RIGHT_SIDE : "right"

	# Creates a new Pane
	#
	# @param side [String] The side the pane needs to be on
	constructor: ( @_side ) ->
		@_id = new Date().getMilliseconds()
		@_paper = @_addPaper()

		super(@_paper)

		@_extended = off
		@_buttonWidth = 40

		@_buttonOptions = {
		}
		@_containerOptions = {
		}
	
	# Resizes the view
	#
	resize: ( ) ->
		@_width = @_container.width()
		@_height = $( window ).height()
		@_paper.setSize( @_width, @_height )
		#@_paper.setViewBox( x, y, @_width, @_height, true )
		
		
	# Draw the view
	#
	# @param side [String] The side the pane needs to be on
	draw: ( side = @_side ) ->
		super()
		[ button, container ] = @_getXY()

		@_contents.push @_drawButton(button.x, button.y)
		@_contents.push @_drawContainer(container.x, container.y)

		if @_extended
			@extend(0)
		else
			@retract(0)
	
	# Get the x and y for this view based on the side
	#
	# @param side [String] The side to base the coordinates on
	#
	_getXY: ( side = @_side ) ->
		switch side
			when View.Pane.LEFT_SIDE
				buttonX = @_width - @_buttonWidth
				buttonY = 0
				containerX = 0
				containerY = 0
			when View.Pane.RIGHT_SIDE
				buttonX = 0
				buttonY = 0
				containerX = @_buttonWidth
				containerY = 0
		button = {
			x : buttonX
			y : buttonY
		}
		container = {
			x : containerX
			y : containerY
		}
		return [button, container]
	
	# Add paper to the container node
	#
	_addPaper: ( ) ->
		unless @_container?
			@_container= @_addContainerNode()

		paper = Raphael("pane-"+@_id,"100%", @_height)
		return paper
	
	# Adds a node to act as the container for the pane
	#
	# @retun [Object] The node that will contain the pane
	_addContainerNode: ( ) ->
		node = $("<div id='pane-" + @_id + "' class='pane pane-" + @_side + "'></div>")
		$( "body" ).append( node )
		
		return node

	# Draw the button to extend or retract the pane
	#
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	_drawButton: ( x, y ) ->
		button = @_paper.rect(x, y, @_buttonWidth, @_height)
		button.attr( @_buttonOptions )
		button.node.setAttribute("class","pane-button")
		button.click((() => @_switchState()))
		return button
	
	# Draws container and any elements to be drawn within it
	#
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	_drawContainer: ( x, y ) ->
		box = @_paper.rect(x, y, @_width - @_buttonWidth, @_height).attr(@_containerOptions)
		box.node.setAttribute("class","pane-container")
		box.toBack()
		return box
	
	# Switches the pane from extended to retracted and vice versa
	#
	_switchState: ( ) ->
		if @_extended
			@retract()
		else
			@extend()
		
	
	# Extends the pane if not already extended
	#
	# @param time [Integer] The time for the animation to take
	#
	extend: ( time = 500 ) ->
		unless @_extended
			console.log("Extending")
			switch @_side
				when View.Pane.LEFT_SIDE
					animation = {left: 0}
				when View.Pane.RIGHT_SIDE
					animation = {right: 0}
			@_container.animate(animation, time)
			@_extended = on

	
	# Retracts the pane if not already retracted
	#
	# @param time [Integer] The time for the animation to take
	#
	retract: ( time = 500 ) ->
		if @_extended?
			console.log("Retracting")

			switch @_side
				when View.Pane.LEFT_SIDE
					animation = {left: (@_width - @_buttonWidth) * -1}
				when View.Pane.RIGHT_SIDE
					animation = {right: (@_width - @_buttonWidth) * -1}
			@_container.animate(animation, time)
			@_extended = off

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
	
	# Gets the view placement for a specific view
	#
	# @param view [View.Base] The view to get placement for
	# @return [Object] An object containing an x and y for the view
	_getViewPlacement:( view ) ->
		x = 100
		y = 100
		return {x: x, y: y}

(exports ? this).View.Pane = View.Pane
