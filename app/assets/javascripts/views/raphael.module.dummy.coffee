# The module dummy view shows a potential module.
# It also allows for interaction adding this potential module to a cell.
#
class View.DummyModule extends View.RaphaelBase
	
	# Creates a new module view
	# 
	# @param paper [Raphael.Paper] the raphael paper
	# @param _parent [View.cell] the cell view this dummy belongs to
	# @param _cell [Model.Cell] the cell model displayed in the parent
	# @param _module [Function] the module constructor
	# @param _number [Integer] the number of instances allowed [ -1 is unlimted, 0 is none ]
	# @param _params [Object] the params
	#
	constructor: ( paper, @_parent, @_cell, @_module, @_number, @_params = {} ) ->
		super paper
		@activated = off
		@_type = @_module.name
		
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
		
		switch @_type
		
			when "DNA"
				@_visible = off
				@_cell.add( new Model.DNA() )
				
			when "Lipid"
				@_visible = off
				@_cell.add( new Model.Lipid() )
				
			when "Metabolite"
				
				#@_visible = on
				#@activated = off
				@_visible = off
				
				@_cell.addMetabolite( @_params.name, @_params.amount, @_params.supply, @_params.inside_cell, @_params.is_product )
				
			when "Transporter"
					
				@_visible = on

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
				
				@_cell.add new Model.Metabolism()
				@_cell.addProduct( 'p', 0, true )
				@_cell.addSubstrate( 's', 0, 0, true )
				
			when "Protein"
				@_visible = off
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
		
		switch @_type
									
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
		
		classname = 'module-box inactive'
		classname += ' hovered' if @_hovered
		classname += ' selected' if @_selected
		box.node.setAttribute( 'class', classname )
		box.attr
			r: 10 * scale
			
		return box