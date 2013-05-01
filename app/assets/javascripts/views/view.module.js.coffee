class View.Module
	
	# Creates a new module view
	# 
	# @param module [Model.Module] the module to show
	#
	constructor: ( module ) ->
		@_paper = Main.view.paper

		@module = module		
		@type = module.constructor.name
		@name = module.name
		
		@_x = 0
		@_y = 0
		@_scale = 0

		@_selected = false		

		$(document).on('moduleInvalidated', @onModuleInvalidated)
		
	hashCode : () ->
		hash = 0
		return hash if ( @name.length is 0 )
		for i in [0...@name.length]
			char = @name.charCodeAt i
			hash = ( (hash << 5) - hash ) + char;
			hash = hash & hash
		return hash
	
	hashColor : () ->
		return @numToColor @hashCode()

			
	numToColor : ( num, alpha = off ) ->
		num >>>= 0
		b = ( num & 0xFF )
		g = ( num & 0xFF00 ) >>> 8
		r = ( num & 0xFF0000 ) >>> 16
		a = ( ( num & 0xFF000000 ) >>> 24 ) / 255
		a = 1 unless alpha
		return "rgba(#{[r, g, b, a].join ','})"
		
	# Runs if module is invalidated
	# 
	# @param event [Object] the event raised
	# @param module [Model.Module] the module invalidated
	#
	moduleInvalidated: ( event, module ) =>
		if module is @module
			@draw(@_x, @_y, @_scale)

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
		@_color = @hashColor()

		padding = 8 * scale

		if @_selected
			padding = 20 * scale

		@_contents?.remove()
		@_paper.setStart()
		
		switch @type
		
			when 'Transporter'
			
				# This path constructs the arrow we are showing as a transporter
				arrow = @_paper.path("m #{x},#{y} 0,4.06536 85.154735,0 -4.01409,12.19606 27.12222,-16.26142 -27.12222,-16.26141 4.01409,12.19606 -85.154735,0 z")
				arrow.node.setAttribute('class', 'transporter-arrow')
					
				rect = arrow.getBBox()
				dx = rect.x - x
				dy = rect.y - y
				arrow.translate(-dx - rect.width / 2, 0)
				arrow.scale(scale, scale)

				# This is the circle in which we show the substrate
				substrateCircle = @_paper.circle(x, y, 20 * scale)
				substrateCircle.node.setAttribute('class', 'transporter-substrate-circle')
				substrateCircle.attr
					'fill': @_color
					
				substrate = @module.orig ? "..."
				substrateText = @_paper.text( x, y, _.escape _( substrate ).first() )
				substrateText.node.setAttribute('class', 'transporter-substrate-text')
				substrateText.attr
					'font-size': 18 * scale
					
				if @_selected
				
					# Add transporter text
					text = @_paper.text(x, y - 60 * scale, _.escape @type)
					text.attr
						'font-size': 20 * scale

					arrowRect = arrow.getBBox()
					textRect = text.getBBox()

					# Add title line
					line = @_paper.path("M #{Math.min(arrowRect.x, textRect.x) - padding},#{arrowRect.y - padding} L #{Math.max(arrowRect.x + arrowRect.width, textRect.x + textRect.width) + padding},#{arrowRect.y - padding} z")
					line.node.setAttribute('class', 'module-seperator')

					text = @_paper.text(x, y - 60 * scale, _.escape @type)
					text.attr
						'font-size': 20 * scale
			
			when "Substrate"
			
				substrateCircle = @_paper.circle(x, y, 20 * scale)
				substrateCircle.node.setAttribute('class', 'transporter-substrate-circle')
				substrateCircle.attr
					'fill': @_color
					
				substrate = @module.name ? "..."
				substrateText = @_paper.text( x, y, _.escape _( substrate ).first() )
				substrateText.node.setAttribute('class', 'transporter-substrate-text')
				substrateText.attr
					'font-size': 18 * scale
			
			else
				text = @_paper.text(x, y, _.escape @type)
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

		# Draw close button in the top right corner
		@_close?.remove()
		if @_selected
			rect = @_box?.getBBox()
			if rect
				@_close = @_paper.circle(rect.x + rect.width, rect.y, 15 * scale)
				@_close.node.setAttribute('class', 'module-close')
				@_close.click =>
					@_selected = false
					@draw(@_x, @_y, @_scale)
				#@_close.insertBefore(@_contents)

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
					@draw(@_x, @_y, @_scale)

(exports ? this).View.Module = View.Module