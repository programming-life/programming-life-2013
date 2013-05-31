# The module view shows a module
#
class View.Module extends View.RaphaelBase

	@Location:
		Entrance: 0
		Exit: 1
		Top: 2
		Bottom: 3
		Left: 0
		Right: 1


	@Direction:
		Inward: -1
		Outward: 1

	# Creates a new module view
	#
	# @param paper [Raphael.Paper] the raphael paper
	# @param module [Model.Module] the module to show
	#
	constructor: ( paper, parent, @_cell, @model, @_interaction = on ) ->
		super paper, parent
	
		@_type = @model.constructor.name
		@_name = @model.name

		@_selected = off	
		@_visible = on

		@addBindings()
		@addInteraction() if @_interaction is on
				
		Object.defineProperty( @, 'visible',
			get: ->
				return @_visible
		)
		
		Object.defineProperty( @, 'type',
			get: ->
				return @_type
		)
		
	# Adds interaction to the module ( popovers )
	#
	addInteraction: () ->
		@_propertiesView = new View.ModuleProperties( @, @_parent, @_cell, @model )
		@_notificationsView = new View.ModuleNotification( @, @_parent, @_cell, @model )
	
		@_bind( 'module.selected.changed', @, @onModuleSelected )
		@_bind( 'module.hovered.changed', @, @onModuleHovered )
		return this
		
	# Adds bindings to the module (non-interaction)
	#
	addBindings: () ->
		@_bind( 'module.property.changed', @, @onModuleInvalidated )
		@_bind( 'cell.module.added', @, @onModuleAdded )
		@_bind( 'cell.module.removed', @, @onModuleRemoved )
		@_bind( 'cell.metabolite.added', @, @onMetaboliteAdded )
		@_bind( 'cell.metabolite.removed', @, @onMetaboliteRemoved )
		
	# Adds hitbox interaction (click, mouseout, mouseover)
	#
	addHitBoxInteraction: () ->
		@_hitbox.click =>
			unless @_selected
				_( @_trigger( 'module.selected.changed', @model, [ on ]) ).debounce( 100 )
			else
				_( @_trigger( 'module.selected.changed', @model, [ off ]) ).debounce( 100 )

		@_hitbox.mouseout =>
			_( @_trigger( 'module.hovered.changed', @model, [ off, @_selected ]) ).debounce( 100 )
		
		@_hitbox.mouseover =>
			_( @_trigger( 'module.hovered.changed', @model, [ on, @_selected ]) ).debounce( 100 )
		return this
		
	# Generates a hashcode based on the module name
	#
	# @param hashee [String] the name to use as hash
	# @return [Integer] the hashcode
	#
	hashCode : ( hashee = @_name ) ->
		hash = 0
		return hash if ( hashee.length is 0 )
		for i in [ 0...hashee.length ]
			char = hashee.charCodeAt i
			hash = ( (hash << 5) - hash ) + char;
			hash = hash & hash # cast to 32 bit int
		return hash
	
	# Generates a colour based on the module name
	#
	# @param hashee [String] the name to use as hash
	# @return [String] the CSS color
	#
	hashColor : ( hashee = @_name ) ->
		return '#' + md5( hashee ).slice(0, 6) #@numToColor @hashCode hashee

	# Generates a colour based on a numer
	#
	# @param num [Integer] the seed for the colour
	# @param alpha [Boolean] if on, uses rgba, else rgb defaults to off
	# @param minalpha [Integer] the minimum alpha if on, defaults to 127
	# @return [String] the CSS color
	#
	numToColor : ( num, alpha = off, minalpha = 127 ) ->
		num >>>= 0
		# TODO use higher order bytes too when no alpha
		b = ( num & 0xFF )
		g = ( num & 0xFF00 ) >>> 8
		r = ( num & 0xFF0000 ) >>> 16
		a = ( minalpha ) / 255 + ( ( ( num & 0xFF000000 ) >>> 24 ) / 255 * ( 255 - minalpha ) )
		a = 1 unless alpha
		# (0.2126*R) + (0.7152*G) + (0.0722*B) << luminance
		return "rgba(#{[r, g, b, a].join ','})"

	# Sets wether or not the module is selected
	#
	# @param selected [Boolean] selection state
	#
	_setSelected: ( selected ) ->
		if selected isnt @_selected
			if selected
				@_setHovered off
				$(@_box.node).addClass('selected')
				@_shadow.forEach(( e ) -> $(e.node).addClass('selected'))
			else
				$(@_box.node).removeClass('selected')
				@_shadow.forEach(( e ) -> $(e.node).removeClass('selected'))

		@_selected = selected
		return this

	# Sets wether or not the module is hovered
	#
	# @param hovered [Boolean] hover state
	#
	_setHovered: ( hovered ) ->
		if hovered isnt @_hovered 
			if hovered and not @_selected
				$(@_box.node).addClass('hovered')
			else
				$(@_box.node).removeClass('hovered')

		@_hovered = hovered
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
		
		return super()

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

	# Returns the absolute coordinates of a location
	#
	# @param location [View.Module.Location] the location for which to get the coordinates
	# @return [[float, float]] a tuple of the absolute x and y values, respectively
	#
	getAbsolutePoint: ( location ) ->
		[x, y] = @getPoint(location)
		return @getAbsoluteCoords(x, y)

	# Returns the direction in which a spline should be drawn wrt a metabolite
	#
	# @param metabolitePlacement [Placement] the placement of the metabolite
	# @return [View.Module.Direction] the direction of the spline
	#
	_getSplineDirection: ( metabolitePlacement ) ->
		if @_type is 'Transporter'
			switch @model.direction
				when Model.Transporter.Inward
					switch metabolitePlacement
						when Model.Metabolite.Inside
							return View.Module.Direction.Outward
						when Model.Metabolite.Outside
							return View.Module.Direction.Inward
				when Model.Transporter.Outward
					switch metabolitePlacement
						when Model.Metabolite.Inside
							return View.Module.Direction.Inward
						when Model.Metabolite.Outside
							return View.Module.Direction.Outward

	# Redraws this view iff it has been drawn before
	#
	redraw: ( ) ->
		_( @draw() ).debounce( 50 )
		return this
			
	# Draws this view and thus the model
	#
	draw: ( x = null, y = null ) ->
		unless x? and y?
			[x, y] = @_parent?.getViewPlacement(@) ? [0, 0]

		super(x, y)

		unless @_visible
			return
		
		@color = @hashColor(_.escape _( @model.name ).first())
		
		contents = @drawContents()
		@_contents.push @drawMetaContents( contents )
		@_contents.push contents
		
		@createSplines()
		
		@_trigger( 'view.drawn', @ )

	# Draws the contents (module)
	#
	# @return [Raphael.Set] the contents
	#
	drawContents: () ->
		@_paper.setStart()		
		drawFunction = @["drawAs#{@type}"] ? @drawAsBasic
		drawFunction.call @
		return @_paper.setFinish()
		
	# Draws the meta contents ( shadow, hitbox ... )
	#
	# @param contents [Raphael.Set] the contents to draw meta on
	# @return [Raphael.Set] the metacontents
	#
	drawMetaContents: ( contents ) ->
		@_paper.setStart()
		@_box = @drawBox contents
		@_box.insertBefore contents
		@_shadow = @drawShadow @_box
		@_hitbox = @drawHitbox @_box
		@addHitBoxInteraction() if @_interaction is on
		return @_paper.setFinish()
		
	# Draws this view with basic visualisation
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsBasic: () ->
		text = @_paper.text(@x, @y, _.escape @_type)
		$(text.node).addClass('module-text')
		return [ text ]
		
	# Draws this view as a transporter
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsTransporter: () ->
		[ arrow ] = @drawComponent( 'transporter', 'ProcessArrow', @x, @y, { } )
		params =
			substrate: @model.orig ? "..."
			showText: off
		[ substrateCircle ] = @drawComponent( 'transporter', 'SubstrateCircle', @x, @y, params )
		return [ substrateCircle, arrow ]
		
	# Draws this view as a metabolite
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsMetabolite: () ->
		params =
			substrate: @model.name ? "..."
			showText: on
			
		[ substrateCircle, substrateText ] = @drawComponent( 
			'substrate', 
			'SubstrateCircle', 
			@x, @y, params )
		return [ substrateCircle, substrateText ] 
		
	# Draws this view as a metabolism
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsMetabolism: () ->
		[ arrow ] = @drawComponent( 'transporter', 'ProcessArrow', @x, @y, { } )
				
		params =
			orig: @model.orig ? [ "..." ]
			dest: @model.dest ? [ "..." ]
			showText: off
		[ enzymCirclesOrig, enzymCircleDests ] = @drawComponent( 'enzym', 'EnzymCircle', @x, @y, params )
		
		return [ enzymCirclesOrig, enzymCircleDests, arrow ]
		
	# Draws this view as a protein
	#
	# @return [Array<Raphael>] the contents
	#
	drawProtein: () ->
		params =
			substrate: @model.name ? "..."
			showText: on
			useFullName : on
			r: 45
			
		[ substrateCircle, substrateText ] = @drawComponent( 
			'Protein', 
			'SubstrateCircle', 
			@x, @y, params )
		return [ substrateCirlce, substrateText ]
		
	# Draws this view as a DNA
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsDNA: () -> @drawAsBasic()
	
	# Draws this view as a Lipid
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsLipid: () -> @drawAsBasic()
	
	# Draws this view as a cell growth
	#
	# @return [Array<Raphael>] the contents
	#
	drawAsCellGrowth: () -> @drawAsBasic()

	# Draws this view bounding box
	#
	# @return [Raphael] the contents
	#
	drawBox : ( elem ) ->
		rect = elem.getBBox()
		padding = 15

		switch @type
			when 'Metabolite'
				maxX = Math.max(rect.x2 - @x, @x - rect.x)
				maxY = Math.max(rect.y2 - @y, @y - rect.y)
				radius = Math.max(maxX, maxY) + padding
				box = @_paper.circle(@x, @y, radius)
			else
				box = @_paper.rect(rect.x - padding, rect.y - padding, rect.width + 2 * padding, rect.height + 2 * padding)
				box.attr('r', 9)

		$( box.node ).addClass 'module-box'
		$( box.node ).addClass  @type.toLowerCase() + '-box'
		
		return box
		
	# Creates splines for this module
	#
	createSplines: () ->
		if @type is 'Transporter'
			for property in [ 'orig', 'dest' ]
				metabolite = @_cell.getMetabolite @model[ property ]
				if metabolite
					placement = metabolite.placement
					view = @_parent.getView(metabolite)
					direction = @_getSplineDirection(placement)

					if direction is View.Module.Direction.Inward
						@_createSpline view, @
					else if direction is View.Module.Direction.Outward
						@_createSpline @, view

		else if @type is 'Metabolism'
			for metabolite in @model.orig.map( ( name ) => @_cell.getMetabolite name ) when metabolite?
				view = @_parent.getView(metabolite)
				@_createSpline view, @

			for metabolite in @model.dest.map( ( name ) => @_cell.getMetabolite name ) when metabolite?
				view = @_parent.getView(metabolite)
				@_createSpline @, view
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
		hitbox = @_paper.rect(rect.x, rect.y, rect.width, rect.height)
		hitbox.node.setAttribute( 'class', 'module-hitbox ' + @type.toLowerCase() + '-hitbox' )	
		return hitbox

	# Draw a component
	#
	# @param module [String] module name for classes
	# @param component [String] component string
	# @param x [Integer] x position
	# @param y [Integer] y position
	# @param params [Object] options
	# @return [Array<Object>] The drawn components
	#
	drawComponent : ( module, component, x, y, params = {} ) ->
		switch component
			when 'ProcessArrow'
				arrow = @_paper.path("m #{x-50},#{y} 0,4.06536 85.154735,0 -4.01409,12.19606 27.12222,-16.26142 -27.12222,-16.26141 4.01409,12.19606 -85.154735,0 z")
				arrow.node.setAttribute( 'class', "#{module}-arrow" )
					
				rect = arrow.getBBox()
				dx = rect.x - x
				dy = rect.y - y
				
				return [ arrow ]
				
			when 'SubstrateCircle'
			
				# This is the circle in which we show the substrate
				substrate = params.substrate
				substrateText = _.escape _( substrate ).first()
				if ( params.useFullName? and params.useFullName )
					substrateText = substrate
				substrateCircle = @_paper.circle( x, y, params.r ? 20 )
				substrateCircle.node.setAttribute('class', "#{module}-substrate-circle" )
				substrateCircle.attr
					'fill': @hashColor substrateText
				
				if ( params.showText )
					substrateTextShadow = @_paper.text( x, y - 1, substrateText )
					substrateTextShadow.node.setAttribute('class', "#{module}-substrate-text-shadow" )

					substrateTextActual = @_paper.text( x, y, substrateText )
					substrateTextActual.node.setAttribute('class', "#{module}-substrate-text" )

					substrateText = @_paper.set()
					substrateText.push(substrateTextShadow, substrateTextActual)
				
				return [ substrateCircle, substrateText ]
				
			when 'Sector'
				r = params.r
				startAngle = params.from
				endAngle = params.to
				rad = Math.PI / 180;
				x1 = x + r * Math.cos( -startAngle * rad)
				x2 = x + r * Math.cos( -endAngle * rad)
				y1 = y + r * Math.sin( -startAngle * rad)
				y2 = y + r * Math.sin( -endAngle * rad )
				path = @_paper.path( ["M", x, y, "L", x1, y1, "A", r, r, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"] )
				path.node.setAttribute('class', "#{module}-substrate-sector")
				return [ path ]
				
			when 'EnzymCircle'
			
				# This is the circle in which we show the conversion
				
				origTexts = []
				enzymOrigCircles = []
				
				min = 90 
				max = 270
				d = ( max - min ) / params.orig.length 				
				
				for orig in params.orig
				
					from = min + origTexts.length * d 
					to = max - ( params.orig.length - origTexts.length - 1 ) * d
					
					origTexts.push _.escape _( orig ).first()
					
					[ enzymOrigCircle ] = @drawComponent( 'enzym', 'Sector', x - 2, y, { r: 20, from: from, to: to } )
					enzymOrigCircle.attr
						'fill': @hashColor origTexts[ origTexts.length - 1 ]
					enzymOrigCircles.push enzymOrigCircle
					
				destTexts = []
				enzymDestCircles = []
				
				min = 270
				max = 90
				d = ( max - min ) / params.dest.length 				
				
				for dest in params.dest
				
					from = min - ( params.dest.length - destTexts.length - 1 ) * d 
					to = max + destTexts.length * d 
					
					destTexts.push _.escape _( dest ).first()
					
					[ enzymDestCircle ] = @drawComponent( 'enzym', 'Sector', x + 2, y, { r: 20, from: from, to: to } )
					enzymDestCircle.attr
						'fill': @hashColor destTexts[ destTexts.length - 1 ]
					enzymDestCircles.push enzymDestCircle
				
				destText = _.escape _( params.dest ).first()
				
				if ( params.showText )
				
					substrateTextShadow = @_paper.text( x, y - 1, substrateText )
					substrateTextShadow.node.setAttribute('class', "#{module}-substrate-text-shadow" )
					substrateTextShadow.attr
						'font-size': 18 

					substrateTextActual = @_paper.text( x, y, substrateText )
					substrateTextActual.node.setAttribute('class', "#{module}-substrate-text" )
					substrateTextActual.attr
						'font-size': 18

					substrateText = @_paper.set()
					substrateText.push(substrateTextShadow, substrateTextActual)
				
				return [ enzymOrigCircles, enzymDestCircles, substrateText ]
								
		return []

	# Creates a new spline
	#
	# @param orig [View.Module] the origin module view
	# @param dest [View.Module] the destination module view
	# @return [View.Spline] the created spline
	#
	_createSpline: ( orig, dest ) ->
		new View.Spline(@_paper, @_parent, @_cell, orig, dest)
		#return 

	# Runs if module is invalidated
	# 
	# @param module [Model.Module] the module invalidated
	#
	onModuleInvalidated: ( module ) =>
		if module is @model
			@redraw()
	
	# Gets called when a module view selected.
	#
	# @param module [Module] the module that is being selected
	# @param selected [Boolean] the selection state of the module
	#
	onModuleSelected: ( module, selected ) ->
		if module is @model 
			if @_selected isnt selected
				@_setSelected selected 
		else if @_selected isnt off
			@_setSelected off

	# Gets called when a module view hovered.
	#
	# @param module [Module] the module that is being hovered
	# @param selected [Boolean] the hover state of the module
	#
	onModuleHovered: ( module, hovered ) ->
		if module is @model 
			if @_hovered isnt hovered
				@_setHovered hovered
		else if @_hovered isnt off
			@_setHovered off

	# Gets called when a module is added to a cell
	#
	# @param cell [Model.Cell] the cell to which the module was added
	# @param module [Module] the module that was added
	#
	onModuleAdded: ( cell, module ) ->
		

	# Gets called when a module is removed from a cell
	#
	# @param cell [Model.Cell] the cell from which the module was removed
	# @param module [Module] the module that was removed
	#
	onModuleRemoved: ( cell, module ) ->
		if @getFullType() is module.getFullType()
			@setPosition()

	# Gets called when a metabolite is added to a cell
	#
	# @param cell [Model.Cell] the cell to which the metabolite was added
	# @param metabolite [Metabolite] the metabolite that was added
	#
	onMetaboliteAdded: ( cell, metabolite ) ->
		if @type is 'Transporter'
			if metabolite.name is @model.orig
				@_createSpline @_parent.getView(metabolite), @
			else if metabolite.name is @model.dest
				@_createSpline @, @_parent.getView(metabolite)
		else if @type is 'Metabolism'
			if metabolite.name in @model.orig
				@_createSpline @_parent.getView(metabolite), @
			else if metabolite.name in @model.dest
				@_createSpline @, @_parent.getView(metabolite)

	# Gets called when a metabolite is removed from a cell
	#
	# @param cell [Model.Cell] the cell from which the metabolite was removed
	# @param metabolite [Metabolite] the metabolite that was removed
	#
	onMetaboliteRemoved: ( cell, metabolite ) ->
		if @getFullType() is metabolite.getFullType()
			@setPosition()		
