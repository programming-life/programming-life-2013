# The module dummy view shows a potential module.
# It also allows for interaction adding this potential module to a cell.
#
class View.DummyModule extends View.RaphaelBase
	
	# Creates a new module view
	# 
	# @param paper [Raphael.Paper] the raphael paper
	# @param _parent [View.cell] the cell view this dummy belongs to
	# @param _cell [Model.Cell] the cell model displayed in the parent
	# @param _modulector [Function] the module constructor
	# @param _number [Integer] the number of instances allowed [ -1 is unlimted, 0 is none ]
	# @param _params [Object] the params
	#
	constructor: ( paper, parent, @_cell, @_modulector, @_number, @_params = {} ) ->
		
		super paper, parent
		
		@_type = @_modulector.name
		@_count = @_cell.numberOf @_modulector
		@_visible = @_number is -1 or @_count < @_number

		@_bind( 'cell.module.added', @, @onModuleAdd )
		@_bind( 'cell.module.removed', @, @onModuleRemove )
		@_bind( 'cell.metabolite.added', @, @onModuleAdd )		
		@_bind( 'cell.metabolite.removed', @, @onModuleRemove )
		@_bind( 'paper.resize', @, @onPaperResize)
		
		@_bind( 'module.creation.finished', @, @onModuleCreationFinished )
		
		# Here you would like to load a module properties view that calls the dummy.add.activate event on save
		# The correct constructor gets auto called and no need to check it anymore :)
		#
		#@_propertiesView = new View.ModuleProperties( @, @_parent, @_cell, @_modulector )
		@_propertiesView = new View.DummyModuleProperties( @, @_parent, @_cell, @_modulector )
		@_notificationsView = new View.ModuleNotification( @, @_parent, @_cell, @_modulector )
		
		Object.defineProperty( @, 'visible',
			get: ->
				return @_visible
		)
		
		Object.defineProperty( @, 'type',
			get: ->
				return @_type
		)
		
		Object.defineProperty( @, 'module',
			get: ->
				return @_params
		)
		

	# Runs if paper is resized
	#
	onPaperResize: ( ) =>
		if @_selected
			@redraw()
		@_notificationsView.draw()	
		
	# Clicked the add button
	#
	# @params caller [Context] the caller of the event
	# @params dummy [View.DummyModule] the dummy to activate
	# @params params [Object] the params to pass to the constructor
	#
	onModuleCreationFinished : ( dummy, params ) ->
		if dummy isnt this
			return

		params = _( params ).defaults( @_params )
		module = new @_modulector( _( params ).clone( true ) )			
		@_cell.add module
		@_trigger('module.selected.changed', module, [ on ])
		
		console.log params
		switch @_type
			when "Transporter"
				if params.direction is Model.Transporter.Outward
					@_cell.addProduct( params.transported , 0, false )
				if params.direction is Model.Transporter.Inward
					@_cell.addSubstrate( params.transported , 0, 0, true )
			when "Metabolism"
				@_cell.addSubstrate( params.orig , 0, 0, true )
				@_cell.addProduct( params.dest , 0, true )
				
	# On Module Added to the Cell
	#
	# @param cell [Model.Cell] the cell added to
	# @param module [Model.Module] the module added
	#
	onModuleAdd : ( cell, module ) ->
		if cell is @_cell and module instanceof @_modulector 
			@_count += 1
			if @_number isnt -1 and @_number <= @_count
				@hide() if @_visible

	# On Module Removed from the Cell
	#
	# @param cell [Model.Cell] the cell removed from
	# @param module [Model.Module] the module removed
	#
	onModuleRemove : ( cell, module ) ->
		if cell is @_cell and module instanceof @_modulector 
			@_count -= 1
			if @_number > @_count
				@show() unless @_visible
					# Redraws this view iff it has been drawn before

	# Returns the bounding box of this view
	#
	# @return [Object] a bounding box object with coordinates
	#
	getBBox: ( ) -> 
		return @_box?.getBBox() ? { x:0, y:0, x2:0, y2:0, width:0, height:0 }

	# Returns the coordinates of either the entrance or exit of this view
	#
	# @param location [View.Module.Location] the location (entrance or exit)
	# @return [[float, float]] a tuple of the x and y coordinates
	#
	getPoint: ( location ) ->
		box = @getBBox()

		switch location
			when View.Module.Location.Left
				return [box.x ,@y]
			when View.Module.Location.Right
				return [box.x2 ,@y]
			when View.Module.Location.Top
				return [@x, box.y]
			when View.Module.Location.Bottom
				return [@x, box.y2]

	getAbsolutePoint: ( location ) ->
		[x, y] = @getPoint(location)
		return @getAbsoluteCoords(x, y)

	# Draws this view
	#
	draw: ( x, y ) ->
		
		super x, y
		padding = 15
		
		# Start a set for contents
		contents = @drawContents( x, y, padding )
		
		# Draw box
		@_box = @drawBox( contents )
		@_box.insertBefore contents
		
		# Draw hitbox
		hitbox = @drawHitbox(@_box)

		hitbox.click =>
			@_trigger('module.creation.started', @)
		
		@_contents.push hitbox
		@_contents.push contents
		@_contents.push @_box
		
	# Hides this view
	#
	hide: () ->
		@_visible = off
		return this
		
	# Shows this view
	#
	show: () ->
		@_visible = on
		return this
		
	kill: () ->
		super()
		@_notificationsView?.kill()
		
	# Draws the box
	#
	# @param elem [Raphael] element to draw for
	# @return [Raphael] the contents
	#
	drawBox : ( elem ) ->
		rect = elem.getBBox()
		padding = 15
		box = @_paper.rect(rect.x - padding, rect.y - padding, rect.width + 2 * padding, rect.height + 2 * padding)

		classname = 'module-box inactive dummy dummy-' + @_type.toLowerCase()
		classname += ' hovered' if @_hovered
		classname += ' selected' if @_selected
		$(box.node).addClass classname
		box.attr('r', 9)
		
		return box
		
	# Draws contents
	#
	# @param x [Integer] x position
	# @param y [Integer] y position
	# @return [Raphael] the contents
	#
	drawContents: ( x, y, padding ) ->
		
		@_paper.setStart()
		text = @_paper.text( x, y, _.escape "Add #{@_type}" )
		$(text.node).addClass('module-text')

		return @_paper.setFinish()
		
	# Draws this view hitbox
	#
	# @param elem [Raphael] element to draw for
	# @return [Raphael] the contents
	#
	drawHitbox : ( elem ) ->
		rect = elem.getBBox()
		hitbox = @_paper.rect(rect.x, rect.y, rect.width, rect.height)
		hitbox.node.setAttribute('class', 'module-hitbox hitdummy-' + @_type.toLowerCase() )	

		return hitbox
