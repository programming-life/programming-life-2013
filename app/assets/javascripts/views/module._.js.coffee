# The module view shows a module
#
class View.Module extends View.Base

	@include Mixin.EventBindings
	
	# Creates a new module view
	#
	# @param paper [Raphael.Paper] the raphael paper
	# @param module [Model.Module] the module to show
	#
	constructor: ( paper, cell, module ) ->
		super(paper)
		@_cell = cell

		@module = module		
		@type = module.constructor.name
		@name = module.name
		
		@_x = 0
		@_y = 0
		@_scale = 0

		@_selected = off	
		@_visible = on
		
		@_allowBindings()
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

	# Runs if module is invalidated
	# 
	# @param module [Model.Module] the module invalidated
	# @param params [Mixed] parameters pushed by event
	#
	onModuleInvalidated: ( module, params... ) =>
		if module is @module
			@redraw()

	# Runs if module is selected
	# 
	# @param module [Model.Module] the module selected/deslected
	# @param selected [Mixed] selected state
	#
	onModuleSelected: ( module, selected ) =>
		
		# If action runs on this module
		if module is @module 
		
			# State changed
			if selected isnt @_selected
				@_selected = selected
				@redraw()

		# Deselect if was selected 
		else if selected is @_selected is on
			@_selected = off
			@redraw()

	# Runs if module is hovered
	# 
	# @param module [Model.Module] the module hovered/dehovered
	# @param selected [Mixed] hovered state
	#
	onModuleHovered: ( module, hovered ) =>
		
		if module is @module 
			
			if hovered isnt @_hovered
				@_hovered = hovered
				@redraw() unless @_selected

		else if hovered is @_hovered is on
		
			@_hovered = off
			@redraw() unless @_selected

		# Make sure a selected module is always placed at the front
		# no longer hovering a module.
		else if hovered is off and @_selected
			_.defer( => @redraw() )

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
		@clear()
		return this		

	# Redraws this view iff it has been drawn before
	#
	redraw: ( ) ->
		if @_x and @_y and @_scale
			_( @draw( @_x, @_y, @_scale ) ).throttle( 50 )
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
		@_x = x
		@_y = y
		@_scale = scale
		@_color = @hashColor()

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
		box = @drawBox(contents, scale)
		box.insertBefore(contents)

		# Draw shadow
		if @_selected
			closeButton = @drawCloseButton( box, scale )
			closeButton?.click =>
				console.log @module.id, 'close'
				Model.EventManager.trigger( 'module.set.selected' , @module, [ off ])

			deleteButton = @drawDeleteButton( box, scale )
			deleteButton?.click =>
				console.log @module.id, 'delete'
				@_cell.remove( @module )

			editButton = @drawEditButton( box, scale )
			editButton?.click =>
				console.log @module.id, 'edit'
				@_cell.remove( @module )

			shadow = @drawShadow(box, scale)

		# Draw hitbox
		hitbox = @drawHitbox(box, scale)
		hitbox.click =>
			Model.EventManager.trigger( 'module.set.selected', @module, [ on ] )

		if @_hovered
			hitbox.mouseout =>			
				_( Model.EventManager.trigger( 'module.set.hovered', @module, [ off ]) ).debounce( 100 )
		else 
			hitbox.mouseover =>
				_( Model.EventManager.trigger( 'module.set.hovered', @module, [ on ]) ).debounce( 100 )

		@_view = @_paper.setFinish()
		@_view.push( contents )

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
					
				if big
					params = 
						objRect : arrow.getBBox()
						title: _.escape @type
						padding: padding
					
					[ titleText, titleLine ] = @drawComponent( 'module', 'ModuleTitle', x, y, scale, params )
					
					params = 
						objRect : arrow.getBBox()
						title: _.escape @type
						padding: padding
					
					[ titleText, titleLine ] = @drawComponent( 'module', 'ModuleTitle', x, y, scale, params )
					
					params = 
						objRect : arrow.getBBox()
						text: "name: #{@module.name}\ninitial:  #{@module.starts.name}\nk: #{@module.k}\nk_tr: #{@module.k_tr}\nk_m: #{@module.k_m}\nsynth: #{@module.consume}\n#{@module.orig} > #{@module.dest}"
						padding: padding
					
					[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, substrateCircle.getBBox().y + substrateCircle.getBBox().height + 40 * scale , scale, params )
			
			when "Metabolite"		
			
				params =
					substrate: @module.name ? "..."
					showText: on
					
				[ substrateCircle, substrateText ] = @drawComponent( 
					'substrate', 
					'SubstrateCircle', 
					x, y, scale, params )
					
				if big
	
					params = 
						objRect : substrateCircle.getBBox()
						text: "name: #{@module.name}\ninitial:  #{@module.starts.name}"
						padding: padding
					
					[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, y, scale, params )
				

			when "Metabolism"
			
				[ arrow ] = @drawComponent( 'transporter', 'ProcessArrow', x, y, scale, { } )
				
				params =
					orig: @module.orig ? "..."
					dest: @module.dest ? "..."
					showText: off
				
				[ enzymCircleOrig, enzymCircleDest ] = @drawComponent( 'enzym', 'EnzymCircle', x, y, scale, params )
					
				if big
								
					params = 
						objRect : arrow.getBBox()
						title: _.escape @type
						padding: padding
					
					[ titleText, titleLine ] = @drawComponent( 'module', 'ModuleTitle', x, y, scale, params )
					
					params = 
						objRect : arrow.getBBox()
						text: "name: #{@module.name}\ninitial:  #{@module.starts.name}\nk: #{@module.k}\nk_m: #{@module.k_m}\nk_d: #{@module.k_d}\nv: #{@module.v}\n#{@module.orig} > #{@module.dest}"
						padding: padding
					
					[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, enzymCircleOrig.getBBox().y + enzymCircleOrig.getBBox().height + 40 * scale , scale, params )
				
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
					
				if big
					params = 
							objRect : substrateCircle.getBBox()
							text: "name: #{@module.name}\ninitial:  #{@module.starts.name}\nk: #{@module.k}\nk_d: #{@module.k_d}\nsynth: #{@module.consume}\n#{@module.consume} > #{@module.name}"
							padding: padding
						
						[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, substrateCircle.getBBox().y + substrateCircle.getBBox().height + 40 * scale , scale, params )
					
			when "DNA"
						
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale
				
				if big
	
					params = 
						objRect : text.getBBox()
						text: "initial:  #{@module.starts.name}\nk: #{@module.k}\nsynth: #{@module.consume}\n#{@module.consume} > #{@module.name}"
						padding: padding
					
					[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, y, scale, params )
					
			when "Lipid"
						
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale
				
				if big
	
					params = 
						objRect : text.getBBox()
						text: "initial:  #{@module.starts.name}\nk: #{@module.k}\nsynth: #{@module.consume}\n#{@module.consume} > #{@module.name}"
						padding: padding
					
					[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, y, scale, params )
					
			when "CellGrowth"
						
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale
				
				if big
	
					params = 
						objRect : text.getBBox()
						text: "initial cell:  #{@module.starts.name}\ninfrastructure: #{@module.infrastructure}\nsynth: #{@module.metabolites}\n#{@module.infrastructure}, #{@module.metabolites} > #{@module.name}"
						padding: padding
					
					[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, y, scale, params )
					
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
		
		classname = 'module-box'
		classname += ' hovered' if @_hovered
		classname += ' selected' if @_selected
		box.node.setAttribute( 'class', classname )
		box.attr
			r: 10 * scale

		return box

	# Draws this view close buttons
	#
	# @param elem [Raphael] element to draw for
	# @param scale [Integer] the scale
	# @return [Raphael] the contents
	#
	drawCloseButton : ( elem, scale ) ->
		rect = elem.getBBox()

		closeButton = @_paper.set()

		circle = @_paper.circle( rect.x + rect.width, rect.y, 16 * scale )
		circle.node.setAttribute('class', 'module-close')

		image = @_paper.image( 
			'/assets/icon-resize-small.png', 
			rect.x + rect.width - 12 * scale, 
			rect.y - 12 * scale, 
			24 * scale, 
			24 * scale
		)

		hitbox = @_paper.circle( rect.x + rect.width , rect.y, 16 * scale )
		hitbox.node.setAttribute('class', 'module-hitbox')		
		closeButton.push( circle, image, hitbox )
		
		return closeButton

	# Draws the delete buttons
	#
	# @param elem [Raphael] element to draw for
	# @param scale [Integer] the scale
	# @return [Raphael] the contents
	#
	drawDeleteButton : ( elem, scale ) ->
		rect = elem.getBBox()

		deleteButton = @_paper.set()

		circle = @_paper.circle( rect.x, rect.y, 16 * scale )
		circle.node.setAttribute('class', 'module-close')
			
		image = @_paper.image(
			'/assets/icon-trash.png', 
			rect.x - 12 * scale, 
			rect.y - 12 * scale, 
			24 * scale, 
			24 * scale
		)

		hitbox = @_paper.circle( rect.x, rect.y, 16 * scale )
		hitbox.node.setAttribute('class', 'module-hitbox')		
		deleteButton.push( circle, image, hitbox )
		
		return deleteButton

	# Draws the edit buttons
	#
	# @param elem [Raphael] element to draw for
	# @param scale [Integer] the scale
	# @return [Raphael] the contents
	#
	drawEditButton : ( elem, scale ) ->
		rect = elem.getBBox()

		editButton = @_paper.set()

		circle = @_paper.circle( rect.x + 32, rect.y, 16 * scale )
		circle.node.setAttribute('class', 'module-close')
			
		image = @_paper.image(
			'/assets/icon-pencil.png', 
			rect.x + 30 * scale, 
			rect.y - 12 * scale, 
			24 * scale, 
			24 * scale
		)

		hitbox = @_paper.circle( rect.x + 32, rect.y, 16 * scale )
		hitbox.node.setAttribute('class', 'module-hitbox')		
		editButton.push( circle, image, hitbox )
		
		return editButton


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
					substrateText = @_paper.text( x, y, substrateText )
					substrateText.node.setAttribute('class', "#{module}-substrate-text" )
					substrateText.attr
						'font-size': 18 * scale
				
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
				return [ @_paper.path( ["M", x, y, "L", x1, y1, "A", r, r, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"] ) ]
				
			when 'EnzymCircle'
			
				# This is the circle in which we show the conversion
				origText = _.escape _( params.orig ).first()
				destText = _.escape _( params.dest ).first()
				
				[ enzymOrigCircle ] = @drawComponent( 'enzym', 'Sector', x, y, scale, { r: 20, from: 90, to: 270 } );
				enzymOrigCircle.attr
					'fill': @hashColor origText
				[ enzymDestCircle ] = @drawComponent( 'enzym', 'Sector', x, y, scale, { r: 20, from: 270, to: 90 } );
				enzymDestCircle.attr
					'fill': @hashColor destText
				
				if ( params.showText )
				
					substrateText = @_paper.text( x, y, "#{origText}>#{destText}" )
					substrateText.node.setAttribute('class', "#{module}-substrate-text" )
					substrateText.attr
						'font-size': 18 * scale
				
				return [ enzymOrigCircle, enzymDestCircle, substrateText ]
				
				
				
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

(exports ? this).View.Module = View.Module
