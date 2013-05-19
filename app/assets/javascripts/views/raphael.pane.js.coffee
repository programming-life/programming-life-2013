# View for extensible Pane
#
class View.Pane extends View.RaphaelBase
	
	@LEFT_SIDE : "left"
	@RIGHT_SIDE : "right"

	# Creates a new Pane
	#
	# @param side [String] The side the pane needs to be on
	# @param withPaper [Boolean] Wheter to fill the container with a paper or not
	#
	constructor: ( @_side, withPaper = true ) ->
		@_id = new Date().getMilliseconds()

		paper = @_addPaper()
		super(paper, withPaper)

		@_extended = on
		@_buttonWidth = 40

		@_containerOptions = {
		}
	
	# Clears this view
	#
	clear: ( ) ->
		@_container?.remove()
		@_button?.remove()
		super()
	
	# Resizes the view
	#
	resize: ( scaleGraphics = true) ->
		if @_withPaper
			@_width = @_parent.width()
			@_height = $( window ).height()
			@_paper.setSize( @_width, @_height )
			super()
			#@_paper.setViewBox( x, y, @_width, @_height, scaleGraphics)
		else
			@draw()
	
	# Kills the view
	#
	kill: ( ) ->
		super()
		@_container?.remove()
		
	# Draw the view
	#
	# @param side [String] The side the pane needs to be on
	draw: ( side = @_side ) ->
		@clear()
		[ container ] = @_getXY()

		@_button = @_drawButton()
		@_container = @_addContainerNode()

		if @_withPaper
			@_paper = @_addPaper()
			@_contents.push @_drawContainer(container.x, container.y)

		for view in @_views
			if @_withPaper	
				placement = @_getViewPlacement( view )
				view._paper = @_paper
				@_contents.push view.draw( placement.x, placement.y, 1)
			else
				view.draw(@_container)

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
				containerX = 0
				containerY = 0
			when View.Pane.RIGHT_SIDE
				containerX = 0
				containerY = 0
		container = {
			x : containerX
			y : containerY
		}
		return [container]
	
	# Add paper to the container node
	#
	_addPaper: ( ) ->
		unless @_container?
			@_container= @_addContainerNode()

		paper = Raphael(@_container[0],"100%", @_height)
		return paper
	
	_addParentNode: ( ) ->
		parent = $("<div id='pane-" + @_id + "' class='pane pane-" + @_side + "'></div>")
		$( "body" ).append( parent )

		return parent

	# Adds a node to act as the container for the pane
	#
	# @retun [Object] The node that will contain the pane
	_addContainerNode: ( ) ->
		unless @_parent?
			@_parent = @_addParentNode()

		container = $("<div class='pane-container'></div>")
		@_parent.append( container )
		
		return container

	# Draw the button to extend or retract the pane
	#
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	_drawButton: ( x, y ) ->
		button = $("<button class='btn pane-button' type='button'>")
		button.on('click', =>
			@_switchState()
		).on('drag', (event) =>
			@_onDrag(event)
		)

		@_parent.append(button)

		return button
	
	# Draws container and any elements to be drawn within it
	#
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	_drawContainer: ( x, y ) ->
		box = @_paper.rect(x, y, @_width, @_height).attr(@_containerOptions)
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
			@_parent.animate(animation, time)
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
					animation = {left: (@_container.width() ) * -1}
				when View.Pane.RIGHT_SIDE
					animation = {right: (@_container.width() ) * -1}
			@_parent.animate(animation, time)
			@_extended = off
	
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
		x = 200
		y = 200
		return {x: x, y: y}
