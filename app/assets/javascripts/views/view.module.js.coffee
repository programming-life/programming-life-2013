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
		
	# Generates a hashcode based on the module name
	#
	# @param hashee [String] the name to use as hash
	# @returns [Integer] the hashcode
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
	# @returns [String] the CSS color
	#
	hashColor : ( hashee = @name ) ->
		return '#' + md5( hashee ).slice(0, 6) #@numToColor @hashCode hashee
		

	# Generates a colour based on a numer
	#
	# @param num [Integer] the seed for the colour
	# @param alpha [Boolean] if on, uses rgba, else rgb defaults to off
	# @param minalpha [Integer] the minimum alpha if on, defaults to 127
	# @returns [String] the CSS color
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
	# @param event [Object] the event raised
	# @param module [Model.Module] the module invalidated
	#
	moduleInvalidated: ( event, module ) =>
		if module is @module
			@draw(@_x, @_y, @_scale)

	# Draw a component
	#
	# @param module [String] module name for classes
	# @param component [String] component string
	# @param x [Integer] x position
	# @param y [Integer] y position
	# @param scale [Integer] scale
	# @param params [Object] options
	# @returns [Array<Object>] The drawn components
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
				text = @_paper.text( x, y + params.padding * 3, params.text )
				text.attr
					'font-size': 18 * scale

				textRect = text.getBBox()
				
				#line = @_paper.path("M #{Math.min(objRect.x, textRect.x) - params.padding },#{ y + params.padding * 2 } L #{Math.max(objRect.x + objRect.width, textRect.x + textRect.width) + params.padding},#{ y + params.padding * 2 } z")
				
				#line.node.setAttribute('class', "#{module}-seperator" )
				
				return [ text, line ]
		
		return []
			
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
			
				[ arrow ] = @drawComponent( 'transporter', 'ProcessArrow', x, y, scale, { } )
				
				params =
					substrate: @module.orig ? "..."
					showText: off
				
				[ substrateCircle ] = @drawComponent( 'transporter', 'SubstrateCircle', x, y, scale, params )
					
				if @_selected
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
			
			when "Substrate"		
			
				params =
					substrate: @module.name ? "..."
					showText: on
					
				[ substrateCircle, substrateText ] = @drawComponent( 
					'substrate', 
					'SubstrateCircle', 
					x, y, scale, params )
					
				if @_selected
	
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
					
				if @_selected
								
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
					
				if @_selected
					params = 
							objRect : substrateCircle.getBBox()
							text: "name: #{@module.name}\ninitial:  #{@module.starts.name}\nk: #{@module.k}\nk_d: #{@module.k_d}\nsynth: #{@module.substrate}\n#{@module.substrate} > #{@module.name}"
							padding: padding
						
						[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, substrateCircle.getBBox().y + substrateCircle.getBBox().height + 40 * scale , scale, params )
					
			when "DNA"
						
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale
				
				if @_selected
	
					params = 
						objRect : text.getBBox()
						text: "initial:  #{@module.starts.name}\nk: #{@module.k}\nsynth: #{@module.consume}\n#{@module.consume} > #{@module.name}"
						padding: padding
					
					[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, y, scale, params )
					
			when "Lipid"
						
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale
				
				if @_selected
	
					params = 
						objRect : text.getBBox()
						text: "initial:  #{@module.starts.name}\nk: #{@module.k}\nsynth: #{@module.consume}\n#{@module.consume} > #{@module.name}"
						padding: padding
					
					[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, y, scale, params )
					
			when "CellGrowth"
						
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale
				
				if @_selected
	
					params = 
						objRect : text.getBBox()
						text: "initial cell:  #{@module.starts.name}\ninfrastructure: #{@module.infrastructure.join(', ')}\nsynth: #{@module.consume}\n#{@module.infrastructure.join(', ')}, #{@module.consume} > #{@module.name}"
						padding: padding
					
					[ paramsText, paramsLine ] = @drawComponent( 'module', 'Information', x, y, scale, params )
					
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