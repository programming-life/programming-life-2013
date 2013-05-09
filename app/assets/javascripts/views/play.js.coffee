class View.Play
	
	# Creates a new action view
	# 
	# @param paper [Object] Raphael paper
	# @param cell [View.Cell] The view of the cell to simulate
	constructor: ( paper, cell) ->
		@_paper = paper
		@_cell = cell

		@_x = 0
		@_y = 0
		@_scale = 0

		@_selected = off	
		@_visible = on
		
		Object.defineProperty( @, 'visible',
			# @property [Function] the step function
			get: ->
				return @_visible
		)

	# Clears the module view
	#
	clear: () ->
		@_contents?.remove()
		@_box?.remove()
		@_shadow?.remove()
		@_hitBox?.remove() 
			
	# Draws this view and thus the model
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Integer] the scale
	#
	draw: ( x, y, scale ) ->
		@_x = x
		@_y = y
		@_scale = scale

		@_padding = 15 * scale
		
		@_contents?.remove()
		@_contents = @_paper.set()

		if @_play?
			@_play?.remove()
			@_play = null
			@_drawPause()
		else
			@_pause?.remove()
			@_pause = null
			@_drawPlay()

		@_text = @_paper.text(@_x, @_y + 2 * @_padding, "Start Simulation")
		@_text.attr
			'font-size': 20 * scale

		@_contents.push @_text

		# Draw a box around all contents
		@_box?.remove()
		if @_contents?.length > 0
			rect = @_contents.getBBox()
			if rect
				@_box = @_paper.rect(rect.x - @_padding, rect.y - @_padding, rect.width + 2 * @_padding, rect.height + 2 * @_padding)
				@_box.node.setAttribute('class', 'module-box')
				@_box.attr
					r: 10 * scale
				@_box.insertBefore(@_contents)

		# Draw shadow around module view
		@_shadow?.remove()
		@_shadow = @_box?.glow
			width: 35
			opacity: .125
		@_shadow?.scale(.8, .8)


		# Draw hitbox in front of module view to detect mouseclicks
		@_hitBox?.remove()
		if not @_selected
			rect = @_box?.getBBox()
			if rect
				@_hitBox = @_paper.rect(rect.x, rect.y, rect.width, rect.height)
				@_hitBox.node.setAttribute('class', 'module-hitbox')
				@_hitBox.click => 
					@_selected = true

					if @_play
						#start simulation
						console.log("Started simulation")
						@_cell.startSimulation()
					else
						#stop simulation
						console.log("Paused simulation")
						@_cell.stopSimulation()

					@_selected = false
					@draw( @_x, @_y, @_scale )

	_drawPlay: ( ) ->
		@_play = @_paper.triangle(@_x, @_y - @_padding, 2* @_padding).rotate(90)
		@_play.attr({
			"fill" : "black"
		})

		@_contents.push @_play

	_drawPause: ( ) ->
		@_pause = @_paper.set()
		@_pause.push @_paper.rect(@_x - @_padding, @_y - @_padding, @_padding, 2*@_padding).attr({"fill": "black"})
		@_pause.push @_paper.rect(@_x + 0.5* @_padding, @_y - @_padding, @_padding , 2*@_padding).attr({"fill": "black"})

		@_contents.push @_pause...
		
(exports ? this).View.Action = View.Action
