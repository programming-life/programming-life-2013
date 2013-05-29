# The spline view displays pathways between modules
#
class View.Spline extends View.RaphaelBase
	constructor: ( paper, parent, @origin, @destination, @_interaction = on ) ->
		super paper, parent

		@_origDrawn = @_destDrawn = false
		@type = 'Spline'

		@addInteraction() if @_interaction is on		

	_die: ( ) ->
		@_trigger( 'cell.spline.removed', @_parent, [ @ ] )

	# Adds interaction to the spline
	#
	addInteraction: ( ) ->
		@_bind( 'cell.module.removed', @, @onModuleRemove )
		@_bind( 'cell.metabolite.removed', @, @onModuleRemove )

		@_bind( 'module.position.changed', @, @onModuleMove )
		@_bind( 'module.property.changed', @, @onModuleInvalidated )
		@_bind( 'module.drawn', @, @onModuleDraw )

		@_trigger( 'cell.spline.added', @_parent, [ @ ] )

		return this

	setColor: ( ) ->
		if @origin.type is 'Metabolite'
			@color = @origin.color
		else if @destination.type is 'Metabolite'
			@color = @destination.color

		@_contents?.attr('stroke', @color)

	onModuleRemove: ( cell, module ) =>
		if cell is @_parent and ( module is @origin.module or module is @destination.module )
			@_die()

	onModuleMove: ( module ) =>
		if module is @origin.module or module is @destination.module
			@draw()

	onModuleInvalidated: ( module ) =>
		if module.constructor.name is 'Transporter'
			if module is @origin and @origin.transported isnt @destination.name or
					module is @destination and @destination.transported isnt @origin.name
				@_die()
		
		@setColor()

	onModuleDraw: ( module ) =>
		if module is @origin.module
			@_origDrawn = true
		else if module is @destination.module
			@_destDrawn = true

		if @_origDrawn and @_destDrawn
			@draw()

	draw: ( ) ->
		@clear()

		[origX, origY] = @origin.getPoint(View.Module.Location.Exit)
		[destX, destY] = @destination.getPoint(View.Module.Location.Entrance)

		dx = Math.abs(destX - origX)
		dy = destY - origY

		x1 = origX + 2/3 * dx + 20
		y1 = origY + 1/4 * dy
		x2 = destX - 2/3 * dx - 20 
		y2 = destY - 1/4 * dy

		@_contents = @_paper.path("M#{origX},#{origY}C#{x1},#{y1} #{x2},#{y2} #{destX},#{destY}")
		$(@_contents.node).addClass('metabolite-spline')

		@setColor()

		
