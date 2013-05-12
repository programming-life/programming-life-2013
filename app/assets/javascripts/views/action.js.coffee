# Action views are simulated buttons
#
class View.Action
	
	# Creates a new action view
	# 
	# @param paper [Object] Raphael paper
	# @param action [String] the action to view
	# @param params [Object] the parameters
	#
	constructor: ( paper, action, params, func ) ->
		@_paper = paper

		@_params = params
		@_action = action
		
		@_x = 0
		@_y = 0
		@_scale = 0

		@_selected = off	
		@_visible = on
		
		@_func = func
		
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

		padding = 15 * scale
		
		@_contents?.remove()
		@_paper.setStart()
			
		text = @_paper.text(x, y, _.escape @_action )
		text.attr
			'font-size': 20 * scale

		@_contents = @_paper.setFinish()

		# Draw a box around all contents
		@_box?.remove()
		if @_contents?.length > 0
			rect = @_contents.getBBox()
			if rect
				@_box = @_paper.rect(rect.x - padding, rect.y - padding, rect.width + 2 * padding, rect.height + 2 * padding)
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
					@_func.call( @ )
					@_selected = false
					@draw( @_x, @_y, @_scale )

(exports ? this).View.Action = View.Action