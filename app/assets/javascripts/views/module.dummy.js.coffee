class View.DummyModule extends View.Module
	
	# Creates a new module view
	# 
	# @param module [Model.Module] the module to show
	#
	constructor: ( paper, cell, module, params ) ->
		@_cell = cell
		@_params = params
		@_activated = off
		super paper, module
		
	# Activation code
	# 
	#
	onActivate : ( ) ->
		
		switch @type
		
			when "DNA"
				@_visible = off
				@_activated = on
				
				@_cell.add( new Model.DNA() )
				
			when "Lipid"
				@_visible = off
				@_activated = on
				
				@_cell.add( new Model.Lipid() )
				
			when "Substrate"
				
				#@_visible = on
				#@_activated = off
				@_visible = off
				@_activated = on
				
				@_cell.addSubstrate( @_params.name, @_params.amount, @_params.inside_cell, @_params.is_product )
				
			when "Transporter"
					
				@_visible = on
				@_activated = off
				
				if @_params.direction is -1
					@_cell.add Model.Transporter.ext()
					@_cell.addSubstrate( 'p_int', 0, true, true )
					@_cell.addSubstrate( 'p_ext', 0, false, true )
				if @_params.direction is 1
					@_cell.add Model.Transporter.int()
					@_cell.addSubstrate( 's_int', 0, true, false )
					#@_cell.addSubstrate( 's_ext', 0, false, false )
			
			when "Metabolism"
					
				@_visible = on
				@_activated = off
	
				@_cell.add new Model.Metabolism()
				@_cell.addSubstrate( 'p_int', 0, true, true )
				@_cell.addSubstrate( 's_int', 0, true, false )
				
			when "Protein"
				@_visible = off
				@_activated = on
				
				@_cell.add( new Model.Protein() )
				
					
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

		padding = 15 * scale

		if @_selected
			padding = 20 * scale

		@_contents?.remove()
		@_paper.setStart()
		
		if @visible
		
			switch @type
									
				when "DNA"
							
					text = @_paper.text( x, y, _.escape "Add #{@type}" )
					text.attr
						'font-size': 20 * scale
					
						
				when "Lipid"
							
					text = @_paper.text( x, y, _.escape "Add #{@type}" )
					text.attr
						'font-size': 20 * scale
					
				when "Substrate"
				
					text = @_paper.text( x, y, _.escape "Add #{@name}" )
					text.attr
						'font-size': 20 * scale
					
				when "Transporter"
				
					text = @_paper.text( x, y, _.escape "Add #{@name}" )
					text.attr
						'font-size': 20 * scale
										
				else
					text = @_paper.text( x, y, _.escape "Add #{@type}" )
					text.attr
						'font-size': 20 * scale

		@_contents = @_paper.setFinish()
		# Draw a box around all contents
		@_box?.remove()
		
		if @visible and @_contents?.length > 0
				rect = @_contents.getBBox()
				if rect
					@_box = @_paper.rect(rect.x - padding, rect.y - padding, rect.width + 2 * padding, rect.height + 2 * padding)
					@_box.node.setAttribute('class', 'module-box inactive')
					@_box.attr
						r: 10 * scale
					@_box.insertBefore(@_contents)

		# Draw close button in the top right corner
		@_close?.remove()
		@_closeText?.remove()
		
		# Draw shadow around module view
		@_shadow?.remove()
		if @visible
			@_shadow = @_box?.glow
				width: 35
				opacity: .125
			@_shadow?.scale(.8, .8)

		# Draw hitbox in front of module view to detect mouseclicks
		@_hitBox?.remove()
		if @visible
			rect = @_box?.getBBox()
			if rect
				@_hitBox = @_paper.rect(rect.x, rect.y, rect.width, rect.height)
				@_hitBox.node.setAttribute('class', 'module-hitbox inactive')
				@_hitBox.click => 
					@onActivate()
					@draw( @_x, @_y, @_scale )

(exports ? this).View.DummyModule = View.DummyModule