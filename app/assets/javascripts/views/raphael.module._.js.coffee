# The module view shows a module#
class View.Module extends View.RaphaelBase

	# Module Location
	#
	@Location:
	
		Entrance: 0
		Exit: 1
		Top: 2
		Bottom: 3
		Left: 0
		Right: 1
		Center: 4
		
		Global: -1
		Tutorial: -1

	# Module Direction
	#
	@Direction:
		Inward: -1
		Outward: 1

	# Creates a new module view
	#
	# @param paper [Raphael.Paper] the raphael paper
	# @param parent [View.Cell] the cell view
	# @param _cell [Model.Cell] the cell model
	# @param model [Model.Module] the module to show
	# @param _preview [Boolean] the preview flag (is new)
	# @param _interaction [Boolean] the interaction flag
	#
	constructor: ( paper, parent, @_cell, @model, @_preview = off, @_interaction = on ) ->
		super paper, parent

		@id = _.uniqueId('view-module-')
	
		@_type = @model.constructor.name
		@_name = @model.name

		@_selected = @_preview
		@_visible = on

		@addBindings()
		@addInteraction() if @_interaction is on
		@setPreview @_preview
				
		@getter
			type: -> @_type
		
	# Adds interaction to the module ( popovers )
	#
	# @return [self] chainable self
	#
	addInteraction: () ->
		@_propertiesView = new View.ModuleProperties( @, @_parent, @_cell, @model, @_preview )
		@_notificationsView = new View.ModuleNotification( @, @_parent, @_cell, @model )
		return this
		
	# Adds bindings to the module (non-interaction)
	#
	# @return [self] chainable self
	#
	addBindings: () ->
	
		@_bind( 'module.property.changed', @, @_onModuleInvalidated )
		@_bind( 'module.compound.changed', @, @_onModuleInvalidated )
		
		@_bind( 'cell.module.removed', @, @_onModuleRemoved )
		@_bind( 'cell.metabolite.added', @, @_onMetaboliteAdded )
		@_bind( 'cell.metabolite.removed', @, @_onMetaboliteRemoved )
		@_bind( 'view.module.changed', @, @_onChanged )
		return this
		
	# Sets wether or not the module is selected
	#
	# @param selected [Boolean] selection state
	# @return [self] chainable self
	#
	setSelected: ( selected ) ->
		if selected isnt @_selected
			if selected
				@setHovered off
				@_addClass('selected')
			else
				@_removeClass('selected')
				@createSplines()
				
		@_propertiesView?.setSelected selected
		@_selected = selected
		@_notificationsView?.hide()
		return this

	# Sets wether or not the module is hovered
	#
	# @param hovered [Boolean] hover state
	# @return [self] chainable self
	#
	setHovered: ( hovered ) ->
		if hovered isnt @_hovered 
			if hovered and not @_selected
				@_addClass( 'hovered' )
			else
				@_removeClass( 'hovered' )

		@_propertiesView?.setHovered hovered
		@_hovered = hovered
		return this

	# Sets the preview class
	#
	# @param hovered [Boolean] preview state
	# @return [self] chainable self
	#
	setPreview: ( preview ) ->
		if preview
			@_addClass('preview')
		else
			@_removeClass('preview')

		@_preview = preview
		return this

		
	# Returns the full type of this view's module.
	# 
	# @return [String] the full type string
	# 
	getFullType: ( ) ->
	 	return @model.getFullType()
				
	# Kills the module view
	#
	# @return [self] chainable self
	#
	kill: () ->
		@_propertiesView?.kill()
		@_notificationsView?.kill()	
		super()
		return this

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
			when View.Module.Location.Center
				return [@x, @y]

	# Returns the absolute coordinates of a location
	#
	# @param location [View.Module.Location] the location for which to get the coordinates
	# @return [<float, float>] a tuple of the absolute x and y values, respectively
	#
	getAbsolutePoint: ( location ) ->
		[x, y] = @getPoint(location)
		return @getAbsoluteCoords(x, y)

	# Clears this view
	#
	# @return [self] chainable self
	#
	clear: ( ) ->
		super()
		@_clearSplines()
		return this
	
	# Clears the splines form the view
	#
	# @return [self] chainable self
	#
	_clearSplines: () ->
		@each ( view ) => @remove view.kill() if view instanceof View.Spline		
		return this

	# Redraws this view iff it has been drawn before
	#
	# @return [self] chainable self
	#
	redraw: ( ) ->
		@draw()
		return this
		
	#
	#
	previewDraw: ( module = @model, preview = @_preview ) -> 
	
		temp_module = @model
		temp_preview = @_preview
		@model = module
		
		@draw( undefined, undefined, preview )
		
		@model = temp_module
			
	# Draws this view and thus the model
	#
	draw: ( x = null, y = null, splinepreview = @_preview ) ->
		@clear()
		unless x? and y?
			[x, y] = @_parent?.getViewPlacement(@) ? [0, 0]

		super(x, y)

		unless @_visible
			return
		
		@color = Helper.Mixable.hashColor( _.escape @model.name )
		@_contents.push @drawMetaContents( contents = @drawContents() )
		@_contents.push contents

		@createSplines @model, splinepreview
		@setPreview @_preview
		
		@_propertiesView?.setPosition()
		@_contents.transform('S.1').animate Raphael.animation(
			transform: 'S1'
		, 900, 'elastic', => @_propertiesView?.setPosition()
		)
		
		@_trigger( 'view.drawn', @, [] )

	# Draws the contents (module)
	#
	# @return [Raphael.Set] the contents
	#
	drawContents: () ->
		@paper.setStart()
		drawFunction = @["drawAs#{@type}"] ? @drawAsBasic
		drawFunction.call @
		return @paper.setFinish()
		
	# Draws the meta contents ( shadow, hitbox ... )
	#
	# @param contents [Raphael.Set] the contents to draw meta on
	# @return [Raphael.Set] the metacontents
	#
	drawMetaContents: ( contents ) ->
		@paper.setStart()
		@_box = @drawBox contents
		@_box.insertBefore contents
		@_shadow = @drawShadow @_box
		if @_interaction
			@_hitbox = @drawHitbox @_box
		return @paper.setFinish()
		
	# Draws this view with basic visualisation
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsBasic: () ->
		text = @paper.text(@x, @y, _.escape @_type)
		$(text.node).addClass('module-text')
		return [ text ]
		
	# Draws this view as a transporter
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsTransporter: () ->
		[ arrow ] = @_drawProcessArrow( 'transporter', @x, @y )
		params =
			substrate: @model.orig ? "..."
			showText: off
		[ substrateCircle ] = @_drawSubstrateCircle( 'transporter', @x, @y, params )
		return [ substrateCircle, arrow ]
		
	# Draws this view as a metabolite
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsMetabolite: () ->
		params =
			substrate: @model.name ? "..."
			showText: on
		return @_drawSubstrateCircle( 'substrate', @x, @y, params )
		
	# Draws this view as a metabolism
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsMetabolism: () ->
		[ arrow ] = @_drawProcessArrow( 'transporter', @x, @y )
		params =
			orig: @model.orig ? [ "..." ]
			dest: @model.dest ? [ "..." ]
			showText: off
		[ enzymCirclesOrig, enzymCircleDests ] = @_drawEnzymeCircle( 'enzym', @x, @y, params )
		return [ enzymCirclesOrig, enzymCircleDests, arrow ]
		
	# Draws this view as a protein
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsProtein: () ->	
		rect = @paper.rect(@x - 29, @y - 19, 58, 38)
		rect.attr
			fill: @color
			stroke: 'none'
		mask = @paper.image('/img/protein.png', @x - 30, @y - 20, 60, 40)
		set = @paper.set(rect, mask)
		return [ set ]
		
	# Draws this view as a DNA
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsDNA: () ->
		rect = @paper.rect(@x - 39, @y - 29, 78, 58)
		rect.attr
			fill: '#b94a48'
			stroke: 'none'
		mask = @paper.image('/img/dna.png', @x - 40, @y - 30, 80, 60)
		set = @paper.set(rect, mask)
		return [ set ]
	
	# Draws this view as a Lipid
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsLipid: () ->
		rect = @paper.rect(@x - 29, @y - 19, 58, 38)
		rect.attr
			fill: @color
			stroke: 'none'
		mask = @paper.image('/img/lipid.png', @x - 30, @y - 20, 60, 40)
		set = @paper.set(rect, mask)
		return [ set ]
	
	# Draws this view as a cell growth
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsCellGrowth: () -> 
		rect = @paper.rect(@x - 29, @y - 19, 58, 38)
		rect.attr
			fill: @color
			stroke: 'none'
		mask = @paper.image('/img/cellgrowth.png', @x - 30, @y - 20, 60, 40)
		set = @paper.set(rect, mask)
		return [ set ]

	# Draws this view bounding box
	#
	# @return [Raphael] the contents
	#
	drawBox : ( elem ) ->
		rect = elem.getBBox()
		padding = 10

		switch @type
			when 'Metabolite'
				maxX = Math.max(rect.x2 - @x, @x - rect.x)
				maxY = Math.max(rect.y2 - @y, @y - rect.y)
				radius = Math.max(maxX, maxY) + padding
				box = @paper.circle(@x, @y, radius)
			else
				box = @paper.rect(rect.x - padding, rect.y - padding, rect.width + 2 * padding, rect.height + 2 * padding)
				box.attr('r', 9)

		$( box.node ).addClass 'module-box'
		$( box.node ).addClass  @type.toLowerCase() + '-box'
		return box
		
	# Creates splines for this module
	#
	# @param model [Model] the module to create for
	# @param preview [Boolean] the preview flag
	# @return [self] chainable self
	#
	createSplines: ( model = @model, preview = @_preview ) ->
		@_clearSplines()
		
		if @type in ['Transporter', 'Metabolism']

			orig = [].concat(model.orig)
			dest = [].concat(model.dest)

			for metabolite in orig
				if view = @_parent.getViewByName metabolite
					@add new View.Spline( @paper, @_parent, @_cell, view, @, preview, on, View.Spline.Type.Processing )

			for metabolite in dest
				if view = @_parent.getViewByName metabolite
					@add new View.Spline( @paper, @_parent, @_cell, @, view, preview, on, View.Spline.Type.Processing )

		# DNA
		if model.dna?
			if view = @_parent.getViewByName model.dna
				@add new View.Spline( @paper, @_parent, @_cell, view, @, preview, on, View.Spline.Type.Synthesis  )
		
		# Consuming modules
		if model.consume?
			for view_name in model.consume
				if view = @_parent.getViewByName view_name
					@add new View.Spline( @paper, @_parent, @_cell, view, @, preview, on, View.Spline.Type.Consuming  )
		
		
		return this

	# Draws this view shadow
	#
	# @param elem [Raphael] element to draw for
	# @return [Raphael] the contents
	#
	drawShadow : ( elem ) ->
		shadow = elem.glow
			fill: true
			width: 10
			opacity: 1
			color: 'rgba(82, 168, 236, .25)'

		shadow.forEach(( e ) -> $(e.node).addClass('module-shadow'))

		return shadow

	# Draws this view hitbox
	#
	# @param elem [Raphael] element to draw for
	# @return [Raphael] the contents
	#
	drawHitbox : ( elem ) ->
		rect = elem.getBBox()
		hitbox = @paper.rect(rect.x, rect.y, rect.width, rect.height)
		$(hitbox.node).addClass('module-hitbox ' + @type.toLowerCase() + '-hitbox' )	
		$(hitbox.node).attr('id', "#{@id}-button")
		
		$(hitbox.node).off( 'mouseenter' ).off( 'mouseleave' ).off( 'click' )
		
		$(hitbox.node).on( 'mouseenter', ( event ) => @_trigger( 'view.module.hovered', @, [ event, on ] ) )
		$(hitbox.node).on( 'mouseleave', ( event ) => @_trigger( 'view.module.hovered', @, [ event, off ] ) )
		$(hitbox.node).on( 'click', ( event ) => 
			@_trigger( 'view.module.select', @, [ event, not @_selected ] ) 
			@_trigger( 'view.module.selected', @, [ event, not @_selected ] ) 
		)
		return hitbox

	# Draw the processing arrow
	#
	# @param module [String] module name for classes
	# @param x [Integer] x position
	# @param y [Integer] y position
	# @param params [Object] options
	# @return [Array<Object>] The drawn components
	#	
	_drawProcessArrow: ( module, x, y, params ) ->
		arrow = @paper.path("m #{x-50},#{y} 0,4.06536 85.154735,0 -4.01409,12.19606 27.12222,-16.26142 -27.12222,-16.26141 4.01409,12.19606 -85.154735,0 z")
		arrow.node.setAttribute( 'class', "#{module}-arrow" )
			
		rect = arrow.getBBox()
		dx = rect.x - x
		dy = rect.y - y
		
		return [ arrow ]
		
	# Draw a Substrate Circle
	#
	# @param module [String] module name for classes
	# @param x [Integer] x position
	# @param y [Integer] y position
	# @param params [Object] options
	# @return [Array<Object>] The drawn components
	#
	_drawSubstrateCircle: ( module, x, y, params ) ->
		# This is the circle in which we show the substrate
		substrate = _.escape params.substrate
		substrateText = _.escape _( substrate ).first()
		if ( params.useFullName? and params.useFullName )
			substrateText = substrate
		substrateCircle = @paper.circle( x, y, params.r ? 20 )
		substrateCircle.node.setAttribute('class', "#{module}-substrate-circle" )
		substrateCircle.attr
			'fill': Helper.Mixable.hashColor substrate
		
		if ( params.showText )
			substrateTextShadow = @paper.text( x, y - 1, substrateText )
			substrateTextShadow.node.setAttribute('class', "#{module}-substrate-text-shadow" )

			substrateTextActual = @paper.text( x, y, substrateText )
			substrateTextActual.node.setAttribute('class', "#{module}-substrate-text" )

			substrateText = @paper.set()
			substrateText.push(substrateTextShadow, substrateTextActual)
		
		return [ substrateCircle, substrateText ]
		
	# Draw a Substrate Sector
	#
	# @param module [String] module name for classes
	# @param x [Integer] x position
	# @param y [Integer] y position
	# @param params [Object] options
	# @return [Array<Object>] The drawn components
	#
	_drawSector: ( module, x, y, params ) ->
		r = params.r
		startAngle = params.from
		endAngle = params.to
		rad = Math.PI / 180;
		x1 = x + r * Math.cos( -startAngle * rad)
		x2 = x + r * Math.cos( -endAngle * rad)
		y1 = y + r * Math.sin( -startAngle * rad)
		y2 = y + r * Math.sin( -endAngle * rad )
		path = @paper.path( ["M", x, y, "L", x1, y1, "A", r, r, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"] )
		path.node.setAttribute('class', "#{module}-substrate-sector")
		return [ path ]
		
	# Draw an Enzyme Circle
	#
	# @param module [String] module name for classes
	# @param x [Integer] x position
	# @param y [Integer] y position
	# @param params [Object] options
	# @return [Array<Object>] The drawn components
	#
	_drawEnzymeCircle: ( module, x, y, params ) ->
		origFullTexts = []
		origTexts = []
		enzymOrigCircles = []
		
		min = 90 
		max = 270
		d = ( max - min ) / params.orig.length 				
		
		for orig in params.orig
		
			from = min + origTexts.length * d 
			to = max - ( params.orig.length - origTexts.length - 1 ) * d
			
			origFullTexts.push _.escape orig
			origTexts.push _.escape _( orig ).first()
			
			[ enzymOrigCircle ] = @_drawSector( 'enzym', x - 2, y, { r: 20, from: from, to: to } )
			enzymOrigCircle.attr
				'fill': Helper.Mixable.hashColor origFullTexts[ origTexts.length - 1 ]
			enzymOrigCircles.push enzymOrigCircle
			
		destFullTexts = []
		destTexts = []
		enzymDestCircles = []
		
		min = 270
		max = 90
		d = ( max - min ) / params.dest.length 				
		
		for dest in params.dest
		
			from = min - ( params.dest.length - destTexts.length - 1 ) * d 
			to = max + destTexts.length * d 
			
			destFullTexts.push _.escape dest
			destTexts.push _.escape _( dest ).first()
			
			[ enzymDestCircle ] = @_drawSector( 'enzym', x + 2, y, { r: 20, from: from, to: to } )
			enzymDestCircle.attr
				'fill': Helper.Mixable.hashColor destFullTexts[ destTexts.length - 1 ]
			enzymDestCircles.push enzymDestCircle
		

		return [ enzymOrigCircles, enzymDestCircles ]

	# Runs if module is invalidated
	# 
	# @param module [Model.Module] the module invalidated
	#
	_onModuleInvalidated: ( module ) =>
		if module is @model
			@redraw()

	# Gets called when a module is removed from a cell
	#
	# @param cell [Model.Cell] the cell from which the module was removed
	# @param module [Module] the module that was removed
	#
	_onModuleRemoved: ( cell, module ) ->
		return if cell isnt @_cell
		if @getFullType() is module.getFullType() and module isnt @model
			@setPosition()
			
		for view in @_views when view instanceof View.Spline
			if module is view.orig.model or module is view.dest.model
				view.kill()

	# Gets called when a metabolite is added to a cell
	#
	# @param cell [Model.Cell] the cell to which the metabolite was added
	# @param metabolite [Metabolite] the metabolite that was added
	#
	_onMetaboliteAdded: ( cell, metabolite ) ->
		return if cell isnt @_cell
		@createSplines()
		return

	# Gets called when a metabolite is removed from a cell
	#
	# @param cell [Model.Cell] the cell from which the metabolite was removed
	# @param metabolite [Metabolite] the metabolite that was removed
	#
	_onMetaboliteRemoved: ( cell, metabolite ) ->
		return if cell isnt @_cell
		if @getFullType() is metabolite.getFullType() and metabolite isnt @model
			@setPosition()

		for view in @_views when view instanceof View.Spline
			if metabolite is view.orig.model or metabolite is view.dest.model
				view.kill()
	
	_onChanged: ( ) ->
		console.log arguments
