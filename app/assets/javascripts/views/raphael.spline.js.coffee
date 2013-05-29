# The spline view displays pathways between modules
#
class View.Spline extends View.RaphaelBase

	# Creates a new spline
	# 
	# @param paper [Raphael.Paper] the raphael paper
	# @param parent [View.Cell] the cell view this dummy belongs to
	# @param _cell [Model.Cell] the cell model displayed in the parent
	# @param orig [View.Module] the origin of the spline
	# @param dest [View.Module] the destination of the spline
	# @param interaction [Boolean] wether to add interaction to the splines or not
	#
	constructor: ( paper, parent, @_cell, @orig, @dest, @_interaction = on ) ->
		super paper, parent

		@addInteraction() if @_interaction is on		

	# Fires a spline remove event, which should lead to this spline dying
	#
	_die: ( ) ->
		@_trigger( 'cell.spline.remove', @_cell, [ @ ] )

	# Adds interaction to the spline
	#
	addInteraction: ( ) ->
		@_bind( 'cell.module.removed', @, @onModuleRemoved )
		@_bind( 'cell.metabolite.removed', @, @onModuleRemoved )

		@_bind( 'module.property.changed', @, @onModuleInvalidated )

		@_bind( 'module.view.moving', @, @onModuleMoving )
		@_bind( 'module.view.moved', @, @onModuleMoved )
		@_bind( 'module.view.drawn', @, @onModuleDrawn )

		@_trigger( 'cell.spline.add', @_cell, [ @ ] )

		return this

	# Sets the correct color of the spline
	#
	setColor: ( ) ->
		if @orig.type is 'Metabolite'
			@color = @orig.color
		else if @dest.type is 'Metabolite'
			@color = @dest.color

		@_contents?.attr('stroke', @color)

	# Draws the spline
	#
	draw: ( ) ->
		@clear()

		path = @_getPathString()

		@_contents = @_paper.path(path)
		$(@_contents.node).addClass('metabolite-spline')

		@setColor()

	# Returns an svg path string from orig to dest
	#
	# @param origOffsetX [float] an offset to be applied on the origin's x coordinate
	# @param origOffsetY [float] an offset to be applied on the origin's y coordinate
	# @param destOffsetX [float] an offset to be applied on the destination's x coordinate
	# @param destOffsetY [float] an offset to be applied on the destination's y coordinate
	# @return [String] a string representing the path
	#
	_getPathString: ( origOffsetX = 0, origOffsetY = 0, destOffsetX = 0, destOffsetY = 0 ) ->
		[origX, origY] = @orig.getPoint(View.Module.Location.Exit)
		[destX, destY] = @dest.getPoint(View.Module.Location.Entrance)

		origX += origOffsetX
		origY += origOffsetY
		destX += destOffsetX
		destY += destOffsetY

		dx = Math.abs(destX - origX)
		dy = destY - origY

		x1 = origX + 2/3 * dx + 20
		y1 = origY + 1/4 * dy
		x2 = destX - 2/3 * dx - 20 
		y2 = destY - 1/4 * dy

		return "m#{origX},#{origY}C#{x1},#{y1} #{x2},#{y2} #{destX},#{destY}"

	# Gets called when a module is removed from a cell
	#
	# @param cell [Model.Cell] the cell from which the module was removed
	# @param module [Module] the module that was removed
	#
	onModuleRemoved: ( cell, module ) =>
		if cell is @_cell and ( module is @orig.module or module is @dest.module )
			@_die()

	# Gets called when a module is invalidated (had its properties changed)
	#
	# @param module [Module] the module that was invalidated
	#
	onModuleInvalidated: ( module ) =>
		if module.constructor.name is 'Transporter'
			if (module is @orig.module and @orig.module.transported isnt @dest.module.name.split('#')[0]) or
					(module is @dest.module and @dest.module.transported isnt @orig.module.name.split('#')[0])
				@_die()
		else if module.constructor.name is 'Metabolism'
			if (module is @orig.module and @dest.module.name not in @orig.module.dest) or
					(module is @dest.module and @orig.module.name not in @dest.module.orig)
				@_die()
		
		@setColor()

	# Gets called when a module view is about to move (animated)
	#
	# @param module [Module] the module will be moving
	# @param dx [float] the amount to move in the x direction
	# @param dy [float] the amount to move in the y direction
	# @param dt [float] the amount of milliseconds for which to animate
	# @param ease [String] the easing transition being used
	#
	onModuleMoving: ( module, dx, dy, dt, ease ) =>
		if module is @orig.module
			path = @_getPathString(dx, dy, 0, 0)			
		else if module is @dest.module
			path = @_getPathString(0, 0, dx, dy)

		if path?
			@_contents?.animate
				path: path
			, dt, ease

	# Gets called when a module view has moved
	#
	# @param module [Module] the module which has moved
	#
	onModuleMoved: ( module ) =>
		if module is @orig.module or module is @dest.module
			@draw()

	# Gets called when a module view was drawn
	#
	# @param module [Module] the module that was drawn
	#
	onModuleDrawn: ( module ) =>
		if module is @orig.module or module is @dest.module
			@draw()



		
