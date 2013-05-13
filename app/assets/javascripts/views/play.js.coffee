# The play view adds controlls to a cell's simulation.
# 
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
		
		@_playing = false

	# Clears the module view
	#
	clear: () ->
		@_contents?.remove()
		@_box?.remove()
		@_shadow?.remove()
		@_hitBox?.remove() 
		@_play?.remove()
		@_pause?.remove()
			
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
		@_size = 10 * scale
		
		@clear()
		
		@_contents = @_paper.set()

		if @_playing
			@_contents.push @_drawPause( x, y, scale, @_size )...
		else
			@_contents.push @_drawPlay( x, y, scale, @_size )

		# Draw a box around all contents
		if @_contents?.length > 0
			rect = @_contents.getBBox()
			if rect
				@_box = @_paper.rect( rect.x - @_padding, rect.y - @_padding, rect.width + 2 * @_padding, rect.height + 2 * @_padding )
				@_box.node.setAttribute('class', 'module-box')
				@_box.attr
					r: 10 * scale
				@_box.insertBefore( @_contents )

		# Draw shadow around module view
		@_shadow = @_box?.glow
			width: 35
			opacity: .125
		@_shadow?.scale(.8, .8)


		# Draw hitbox in front of module view to detect mouseclicks
		rect = @_box?.getBBox()
		if rect
			@_hitBox = @_paper.rect(rect.x, rect.y, rect.width, rect.height)
			@_hitBox.node.setAttribute('class', 'module-hitbox')
			@_hitBox.click => 
				
				unless @_playing 
					@_cell.startSimulation()
					@_playing = true
				else
					@_cell.stopSimulation()
					@_playing = false

				@draw( @_x, @_y, @_scale )

	# Draws a play button
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Integer] the scale
	# @param size [Integer] the size
	# @return [Raphael] contents
	#
	_drawPlay: ( x, y, scale, size ) ->
		@_play = @_paper.triangle( x , y - size, size * 2 ).rotate( 90 )
		@_play.attr
			fill: "black"
			
		return @_play

	# Draws a pause button
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Integer] the scale
	# @param size [Integer] the size
	# @return [Raphael] contents
	#
	_drawPause: ( x, y, scale, size ) ->
		@_pause = @_paper.set()
		@_pause.push(
			@_paper
				.rect( x - size, y - size, size, 2 * size )
				.attr
					fill: "black"
		)
		@_pause.push(
			@_paper
				.rect( x + size / 2, y - size, size, 2 * size )
				.attr
					fill: "black"
		)
					
		return @_pause
		
(exports ? this).View.Play = View.Play