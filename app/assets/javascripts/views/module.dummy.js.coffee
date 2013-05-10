class View.DummyModule extends View.Module
	
	# Creates a new module view
	# 
	# @param paper [Raphael.Paper] the raphael paper
	# @param cell [Model.Cell] the cell to show
	# @param module [Model.Module] the module to show
	# @param params [Object] the params
	#
	constructor: ( paper, cell, module, params ) ->
		@_cell = cell
		@_params = params
		@_activated = off
		super paper, module
		
	# Runs if module is selected
	# 
	# @param module [Model.Module] the module selected/deslected
	# @param selected [Mixed] selected state
	#
	onModuleSelected: ( module, selected ) =>
		
		# If action runs on this module
		if module is @module 
			if selected
				@onActivate() 
				@redraw()
		
	# Activate button action
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
				
			when "Metabolite"
				
				#@_visible = on
				#@_activated = off
				@_visible = off
				@_activated = on
				
				@_cell.addMetabolite( @_params.name, @_params.amount, @_params.supply, @_params.inside_cell, @_params.is_product )
				
			when "Transporter"
					
				@_visible = on
				@_activated = off
				
				if @_params.direction is Model.Transporter.Outward
					@_cell.add Model.Transporter.ext()
					@_cell.addProduct( 'p', 0, true )
					@_cell.addProduct( 'p', 0, false )
				if @_params.direction is Model.Transporter.Inward
					@_cell.add Model.Transporter.int()
					@_cell.addSubstrate( 's', 0, 0, true )
					#@_cell.addSubstrate( 's_ext', 0, false, false )
			
			when "Metabolism"
					
				@_visible = on
				@_activated = off
	
				@_cell.add new Model.Metabolism()
				@_cell.addProduct( 'p', 0, true )
				@_cell.addSubstrate( 's', 0, 0, true )
				
			when "Protein"
				@_visible = off
				@_activated = on
				
				@_cell.add( new Model.Protein() )
				
					
	# Draws contents
	#
	# @param x [Integer] x position
	# @param y [Integer] y position
	# @param scale [Integer] box scale
	# @param big [Boolean] box is selected or hovered
	# @return [Raphael] the contents
	#
	drawContents: ( x, y, scale, padding, big ) ->
		
		@_paper.setStart()
		
		switch @type
									
			when "DNA"
						
				text = @_paper.text( x, y, _.escape "Add #{@type}" )
				text.attr
					'font-size': 20 * scale
				
					
			when "Lipid"
						
				text = @_paper.text( x, y, _.escape "Add #{@type}" )
				text.attr
					'font-size': 20 * scale
				
			when "Metabolite"
			
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
					
		return @_paper.setFinish()
	
	# Draws the box
	#
	# @param elem [Raphael] element to draw for
	# @param scale [Integer] the scale
	# @return [Raphael] the box raphael
	drawBox : ( elem, scale ) ->
		box = super elem, scale
		box.node.setAttribute('class', 'module-box inactive')
		return box
		