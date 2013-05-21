# The module view shows a module
#
# @concern Mixin.EventBindings
#
class View.Module extends View.RaphaelBase

	@concern Mixin.EventBindings

	Location:
		Entrance: -1
		Exit: 1

	Direction:
		Inward: -1
		Outward: 1

	# Creates a new module view
	#
	# @param paper [Raphael.Paper] the raphael paper
	# @param module [Model.Module] the module to show
	#
	constructor: ( paper, parent, cell, module, params = {} ) ->
		super(paper)
		@_cell = cell
		@_parent = parent

		@module = module		
		@type = module.constructor.name
		@name = module.name

		@_params = params
		
		@x = 0
		@y = 0
		@_scale = 0

		@_selected = off	
		@_visible = on
		@activated = on

		@_propertiesView = new View.ModuleProperties( @, @_parent, @_cell, @module )
		@_notificationsView = new View.ModuleNotification( @, @_parent, @_cell, @module )
		
		@_allowEventBindings()
		
		@_bind( 'module.set.property', @, @onModuleInvalidated )
		@_bind( 'module.set.selected', @, @onModuleSelected )
		@_bind( 'module.set.hovered', @, @onModuleHovered )
		@_bind( 'paper.resize', @, @onPaperResize)
		
		Object.defineProperty( @, 'visible',
			# @property [Function] the step function
			get: ->
				return @_visible
		)
		
	# Generates a hashcode based on the module name
	#
	# @param hashee [String] the name to use as hash
	# @return [Integer] the hashcode
	#
	hashCode : ( hashee = @name ) ->
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
	hashColor : ( hashee = @name ) ->
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
			else
				$(@_box.node).removeClass('selected')

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

	# Runs if module is invalidated
	# 
	# @param module [Model.Module] the module invalidated
	# @param params [Mixed] parameters pushed by event
	#
	onModuleInvalidated: ( module, params... ) =>
		if module is @module
			@redraw()

	# Gets called when a module view selected.
	#
	# @param module [Module] the module that is being selected
	# @param selected [Boolean] the selection state of the module
	#
	onModuleSelected: ( module, selected ) ->
		if module is @module 
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
		if module is @module 
			console.log 'yolo'
			if @_hovered isnt hovered
				@_setHovered hovered
		else if @_hovered isnt off
			@_setHovered off

	# Runs if paper is resized
	#
	onPaperResize: ( ) =>
		if @_selected
			@redraw()


	# Clears the module view
	#
	# @return [self] chainable self
	#
	clear: () ->
		@_view?.remove()
		return this
		
	# Kills the module view
	#
	# @return [self] chainable self
	#
	kill: () ->
		
		@_visible = off
		@_unbindAll()
		
		@_propertiesView.kill()
		@_notificationsView.kill()
		
		@clear()
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
	# @return [[float, float]] a tuple of the x and y coordinates
	#
	getPoint: ( location ) ->
		box = @getBBox()

		switch location
			when @Location.Entrance
				return [box.x ,@y]
			when @Location.Exit
				return [box.x2 ,@y]

	# Returns the direction in which a spline should be drawn wrt a metabolite
	#
	# @param metabolitePlacement [Placement] the placement of the metabolite
	# @return [View.Module.Direction] the direction of the spline
	#
	_getSplineDirection: ( metabolitePlacement ) ->
		if @type is 'Transporter'
			switch @module.direction
				when Model.Transporter.Inward
					switch metabolitePlacement
						when Model.Metabolite.Inside
							return @Direction.Outward
						when Model.Metabolite.Outside
							return @Direction.Inward
				when Model.Transporter.Outward
					switch metabolitePlacement
						when Model.Metabolite.Inside
							return @Direction.Inward
						when Model.Metabolite.Outside
							return @Direction.Outward

	# Redraws this view iff it has been drawn before
	#
	redraw: ( ) ->
		if @x and @y and @_scale
			_( @draw( @x, @y, @_scale ) ).debounce( 50 )
		return this
			
	# Draws this view and thus the model
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Integer] the scale
	#
	draw: ( x, y, scale ) ->
		
		@clear()

		# Store x, y, and scale values for further redraws
		@x = x
		@y = y
		@_scale = scale
		@color = @hashColor(_.escape _( @module.name ).first())

		unless @_visible
			return
		
		# If we're either hovered or selected, we will display a bigger version of the view
		big = @_selected || @_hovered
		padding = 15 * scale

		# Start a set for contents
		contents = @drawContents( x, y, scale, padding, big )

		# Start a new set for the entire view
		@_paper.setStart()

		# Draw box
		@_box = @drawBox(contents, scale)
		@_box.insertBefore(contents)

		# Draw splines
		if @type is 'Transporter' and @activated
			for placement in [Model.Metabolite.Inside, Model.Metabolite.Outside]
				metabolite = @_cell.getMetabolite(@module.transported, placement)
				if metabolite
					metaboliteView = @_parent.getView(metabolite)
					direction = @_getSplineDirection(placement)

					((direction, metaboliteView) =>
						_.defer ( ) =>
							spline = @drawSpline(direction, metaboliteView)
							@_view.push(spline)
							spline.insertAfter(@_paper.bottom)
					) direction, metaboliteView

		else if @type is 'Metabolism' and @activated
			inwards = ([metabolite, @Direction.Inward] for metabolite in @module.orig.map( 
				( name ) => 
					@_cell.getMetabolite(name.split('#')[0], Model.Metabolite.Inside)
				)
			)

			outwards = ([metabolite, @Direction.Outward] for metabolite in @module.dest.map( 
				( name ) => 
					@_cell.getMetabolite(name.split('#')[0], Model.Metabolite.Inside)
				)
			)
			
			for [metabolite, direction] in inwards.concat(outwards)
				if metabolite
					metaboliteView = @_parent.getView(metabolite)
					((direction, metaboliteView) =>
						_.defer ( ) =>
							spline = @drawSpline(direction, metaboliteView)
							@_view.push(spline)
							spline.insertAfter(@_paper.bottom)
					) direction, metaboliteView

		# Draw hitbox
		hitbox = @drawHitbox(@_box, scale)

		hitbox.click =>
			_( @_trigger( 'module.set.selected', @module, [ on ]) ).debounce( 100 )

		hitbox.mouseout =>
			_( @_trigger( 'module.set.hovered', @module, [ off ]) ).debounce( 100 )
		
		hitbox.mouseover =>
			_( @_trigger( 'module.set.hovered', @module, [ on ]) ).debounce( 100 )

		@_view = @_paper.setFinish()
		@_view.push( contents )		

		Model.EventManager.trigger( 'module.drawn', @module )

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
		
			when 'Transporter'
			
				[ arrow ] = @drawComponent( 'transporter', 'ProcessArrow', x, y, scale, { } )
				
				params =
					substrate: @module.orig ? "..."
					showText: off
				
				[ substrateCircle ] = @drawComponent( 'transporter', 'SubstrateCircle', x, y, scale, params )

			when "Metabolite"		
			
				params =
					substrate: @module.name ? "..."
					showText: on
					
				[ substrateCircle, substrateText ] = @drawComponent( 
					'substrate', 
					'SubstrateCircle', 
					x, y, scale, params )
				
			when "Metabolism"
			
				[ arrow ] = @drawComponent( 'transporter', 'ProcessArrow', x, y, scale, { } )
				
				params =
					orig: @module.orig ? [ "..." ]
					dest: @module.dest ? [ "..." ]
					showText: off
				
				[ enzymCirclesOrig, enzymCircleDests ] = @drawComponent( 'enzym', 'EnzymCircle', x, y, scale, params )
									
			when "Protein"	
			
				params =
					substrate: @module.name ? "..."
					showText: on
					useFullName : on
					r: 45
					
				[ substrateCircle, substrateText ] = @drawComponent( 
					'protein', 
					'SubstrateCircle', 
					x, y, scale, params )
										
			when "DNA"
						
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale
					
			when "Lipid"
						
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale
									
			when "CellGrowth"
						
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale
					
			else
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale

		return @_paper.setFinish()

	# Draws this view bounding box
	#
	# @return [Raphael] the contents
	#
	drawBox : ( elem, scale ) ->
		rect = elem.getBBox()
		padding = 15 * scale
		box = @_paper.rect(rect.x - padding, rect.y - padding, rect.width + 2 * padding, rect.height + 2 * padding)

		$(box.node).addClass('module-box')
		box.attr('r', 5)
		
		return box

	# Draws a spline from between two points
	#
	# @param origX [float] the starting x coordinate
	# @param origY [float] the starting y coordinate
	# @param destX [float] the terminal x coordinate
	# @param destY [float] the terminal y coordinate
	# @return [Raphael] the spline path
	#
	drawSpline : ( direction, target ) ->
		switch direction
			when @Direction.Inward
				[origX, origY] = @getPoint(@Location.Entrance)
				[destX, destY] = target.getPoint(@Location.Exit)

				dX = -Math.abs(destX - origX)
				dY = destY - origY

				x1 = origX + 2/3 * dX - 20 * @_scale
				y1 = origY + 1/4 * dY
				x2 = destX - 2/3 * dX + 20 * @_scale
				y2 = destY - 1/4 * dY

			when @Direction.Outward
				[origX, origY] = @getPoint(@Location.Exit)
				[destX, destY] = target.getPoint(@Location.Entrance)

				dX = Math.abs(destX - origX)
				dY = destY - origY

				x1 = origX + 2/3 * dX + 20 * @_scale
				y1 = origY + 1/4 * dY
				x2 = destX - 2/3 * dX - 20 * @_scale
				y2 = destY - 1/4 * dY

		

		spline = @_paper.path("M#{origX},#{origY}C#{x1},#{y1} #{x2},#{y2} #{destX},#{destY}")
		spline.attr('stroke', target.color)
		spline.node.setAttribute('class', 'metabolite-spline')

		return spline


	# Draws this view shadow
	#
	# @param elem [Raphael] element to draw for
	# @param scale [Integer] the scale
	# @return [Raphael] the contents
	#
	drawShadow : ( elem, scale ) ->
		shadow = elem.glow
			width: 35
			opacity: .125
		shadow.scale(.8, .8)

		return shadow

	# Draws this view hitbox
	#
	# @param elem [Raphael] element to draw for
	# @param scale [Integer] the scale
	# @return [Raphael] the contents
	#
	drawHitbox : ( elem, scale ) ->
		rect = elem.getBBox()
		hitbox = @_paper.rect(rect.x, rect.y, rect.width, rect.height)
		hitbox.node.setAttribute('class', 'module-hitbox')	

		return hitbox

	# Draw a component
	#
	# @param module [String] module name for classes
	# @param component [String] component string
	# @param x [Integer] x position
	# @param y [Integer] y position
	# @param scale [Integer] scale
	# @param params [Object] options
	# @return [Array<Object>] The drawn components
	#
	drawComponent : ( module, component, x, y, scale, params = {} ) ->
		switch component
			when 'ProcessArrow'
				arrow = @_paper.path("m #{x},#{y} 0,4.06536 85.154735,0 -4.01409,12.19606 27.12222,-16.26142 -27.12222,-16.26141 4.01409,12.19606 -85.154735,0 z")
				arrow.node.setAttribute( 'class', "#{module}-arrow" )
					
				rect = arrow.getBBox()
				dx = rect.x - x
				dy = rect.y - y
				arrow.translate(-dx - rect.width / 2, 0)
				arrow.scale( scale, scale )
				
				return [ arrow ]
				
			when 'SubstrateCircle'
			
				# This is the circle in which we show the substrate
				substrate = params.substrate
				substrateText = _.escape _( substrate ).first()
				if ( params.useFullName? and params.useFullName )
					substrateText = substrate
				substrateCircle = @_paper.circle( x, y, (params.r ? 20 ) * scale)
				substrateCircle.node.setAttribute('class', "#{module}-substrate-circle" )
				substrateCircle.attr
					'fill': @hashColor substrateText
				
				if ( params.showText )
					substrateTextShadow = @_paper.text( x, y - 1, substrateText )
					substrateTextShadow.node.setAttribute('class', "#{module}-substrate-text-shadow" )
					substrateTextShadow.attr
						'font-size': 18 * scale

					substrateTextActual = @_paper.text( x, y, substrateText )
					substrateTextActual.node.setAttribute('class', "#{module}-substrate-text" )
					substrateTextActual.attr
						'font-size': 18 * scale

					substrateText = @_paper.set()
					substrateText.push(substrateTextShadow, substrateTextActual)
				
				return [ substrateCircle, substrateText ]
				
			when 'Sector'
				r = params.r * scale
				startAngle = params.from
				endAngle = params.to
				rad = Math.PI / 180;
				x1 = x + r * Math.cos( -startAngle * rad)
				x2 = x + r * Math.cos( -endAngle * rad)
				y1 = y + r * Math.sin( -startAngle * rad)
				y2 = y + r * Math.sin( -endAngle * rad )
				path = @_paper.path( ["M", x, y, "L", x1, y1, "A", r, r, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"] )
				path.node.setAttribute('class', "#{module}-substrate-sector")
				return [ @_paper.path( ["M", x, y, "L", x1, y1, "A", r, r, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"] ) ]
				
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
					
					[ enzymOrigCircle ] = @drawComponent( 'enzym', 'Sector', x - 2, y, scale, { r: 20, from: from, to: to } )
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
					
					[ enzymDestCircle ] = @drawComponent( 'enzym', 'Sector', x + 2, y, scale, { r: 20, from: from, to: to } )
					enzymDestCircle.attr
						'fill': @hashColor destTexts[ destTexts.length - 1 ]
					enzymDestCircles.push enzymDestCircle
				
				destText = _.escape _( params.dest ).first()
				
				if ( params.showText )
				
					substrateText = @_paper.text( x, y, "#{origTexts}>#{destTexts}" )
					substrateText.node.setAttribute('class', "#{module}-substrate-text" )
					substrateText.attr
						'font-size': 18 * scale
				
				return [ enzymOrigCircles, enzymDestCircles, substrateText ]
				
				
				
			when 'ModuleTitle'
				# Add title text
				text = @_paper.text( x, y - 60 * scale, params.title )
				text.attr
					'font-size': 20 * scale

				objRect = params.objRect
				textRect = text.getBBox()

				# Add seperation line
				line = @_paper.path("M #{Math.min(objRect.x, textRect.x) - params.padding },#{objRect.y - params.padding } L #{Math.max(objRect.x + objRect.width, textRect.x + textRect.width) + params.padding},#{objRect.y - params.padding} z")
				line.node.setAttribute('class', "#{module}-seperator" )
				
				return [ text, line ]
				
			when 'Information'
				
				objRect = params.objRect
				
				# Add params text
				text = @_paper.text( objRect.x, y + params.padding * 3, params.text )
				text.attr
					'font-size': 18 * scale
					'text-anchor': 'start'

				textRect = text.getBBox()
				
				#line = @_paper.path("M #{Math.min(objRect.x, textRect.x) - params.padding },#{ y + params.padding * 2 } L #{Math.max(objRect.x + objRect.width, textRect.x + textRect.width) + params.padding},#{ y + params.padding * 2 } z")
				
				#line.node.setAttribute('class', "#{module}-seperator" )
				
				return [ text, line ]
		
		return []
