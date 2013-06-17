# The module dummy view shows a potential module.
# It also allows for interaction adding this potential module to a cell.
#
class View.DummyModule extends View.RaphaelBase
	
	# Creates a new module view
	# 
	# @param paper [Raphael.Paper] the raphael paper
	# @param _parent [View.Cell] the cell view this dummy belongs to
	# @param _cell [Model.Cell] the cell model displayed in the parent
	# @param model [Model.Module] the module
	# @param _visible
	#
	constructor: ( paper, parent, @_cell, @_model, @_visible, @_params = {} ) ->
		
		@getter
			visible: -> @_visible
			model: -> @_model
			type: -> @model.constructor.name
			
		@setter
			model: ( value ) -> @_model = value
			
		super paper, parent

	# Returns the bounding box of this view
	#
	# @return [Object] a bounding box object with coordinates
	#
	getBBox: ( ) -> 
		return @_box?.getBBox() ? { x:0, y:0, x2:0, y2:0, width:0, height:0 }

	# Returns the coordinates of either the entrance or exit of this view
	#
	# @param location [View.Module.Location] the location (entrance or exit)
	# @return [<float, float>] a tuple of the x and y coordinates
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

	#
	#
	getAbsolutePoint: ( location ) ->
		[x, y] = @getPoint(location)
		return @getAbsoluteCoords(x, y)

	# Draws this view
	#
	draw: ( x = null, y = null ) ->	
	
		unless x? and y?
			[x, y] = @_parent?.getViewPlacement(@) ? [0, 0]

		super(x, y)

		padding = 15
		
		# Start a set for contents
		contents = @drawContents( @x, @y, padding )
		
		# Draw box
		@_box = @drawBox( contents )
		@_box.insertBefore contents
		
		# Draw hitbox
		hitbox = @drawHitbox( @_box )
		$( hitbox.node ).on( 'mouseenter', ( event ) => @_trigger( 'view.module.hovered', @, [ event, on ] ) )
		$( hitbox.node ).on( 'mouseleave', ( event ) => @_trigger( 'view.module.hovered', @, [ event, off ] ) )
		$( hitbox.node ).on( 'click', ( event ) => 
			@_trigger( 'view.module.select', @, [ event, not @_selected ] ) 
			@_trigger( 'view.module.selected', @, [ event, not @_selected ] ) 
		)
		
		@_contents.push hitbox
		@_contents.push contents
		@_contents.push @_box
				
		@hide off unless @_visible
		
	# Hides this view
	#
	hide: ( animate = on ) ->
		done = ( ) =>
			@_visible = off
			@_contents.hide()
		
		if animate
			@_contents.attr('opacity', 1)
			@_contents.animate Raphael.animation(
				opacity: 0
			, 200, 'ease-in', done)
		else
			done()
			
		console.log 'hide'
		return this
		
	# Shows this view
	#
	show: ( animate = on ) ->
		done = ( ) =>
			@_visible = on
			console.log 'done'

		@setPosition off

		if animate
			@_visible = on
			@_contents.attr('opacity', 0)
			@_contents.show()
			@_contents.animate Raphael.animation(
				opacity: 1
			, 100, 'ease-out', done)
		else
			@_contents.show()
			done()

		console.log 'show'
		return this
		
	# Returns the full type of this view's module.
	# 
	# @return [String] the full type string
	# 
	getFullType: ( ) ->
	 	return @model.getFullType()
		
	# Kills this view
	#
	kill: () ->
		super()
		@_propertiesView?.kill()
		@_notificationsView?.kill()

	# Sets wether or not the module is selected
	#
	# @param selected [Boolean] selection state
	# @return [self] chainable self
	#
	setSelected: ( selected ) ->
		if selected isnt @_selected
			if selected
				@setHovered off
				@_addClass 'selected'
			else
				@_removeClass 'selected'
				
		@_selected = selected
		return this

	# Sets wether or not the module is hovered
	#
	# @param hovered [Boolean] hover state
	# @return [self] chainable self
	#
	setHovered: ( hovered ) ->
		if hovered isnt @_hovered 
			if hovered and not @_selected
				@_addClass 'hovered' 
			else
				@_removeClass 'hovered'

		@_hovered = hovered
		return this
		
	# Draws the box
	#
	# @param elem [Raphael] element to draw for
	# @return [Raphael] the contents
	#
	drawBox : ( elem ) ->
		rect = elem.getBBox()
		padding = 15
		box = @paper.rect(rect.x - padding, rect.y - padding, rect.width + 2 * padding, rect.height + 2 * padding)

		classname = 'module-box inactive dummy dummy-' + @type.toLowerCase()
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
	drawContents: ( ) ->
		
		@paper.setStart()
		text = @paper.text( @x, @y, _.escape "Add #{@type}" )
		$(text.node).addClass('module-text')

		return @paper.setFinish()
		
	# Draws this view hitbox
	#
	# @param elem [Raphael] element to draw for
	# @return [Raphael] the contents
	#
	drawHitbox : ( elem ) ->
		rect = elem.getBBox()
		hitbox = @paper.rect(rect.x, rect.y, rect.width, rect.height)
		hitbox.node.setAttribute('class', 'module-hitbox hitdummy-' + @type.toLowerCase() )	

		return hitbox
