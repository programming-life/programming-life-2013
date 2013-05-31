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

		@_bind( 'view.moving', @, @onViewMoving )
		@_bind( 'view.moved', @, @onViewMoved )
		@_bind( 'view.drawn', @, @onViewDrawn )

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
		@_contents.insertBefore(@_paper.bottom)
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
		if cell is @_cell and ( module is @orig.model or module is @dest.model )
			@_die()

	# Gets called when a module is invalidated (had its properties changed)
	#
	# @param module [Module] the module that was invalidated
	#
	onModuleInvalidated: ( module ) =>
		if module.constructor.name is 'Transporter'
			if (module is @orig.model and @orig.model.transported isnt @dest.model.name.split('#')[0]) or
					(module is @dest.model and @dest.model.transported isnt @orig.model.name.split('#')[0])
				@_die()
		else if module.constructor.name is 'Metabolism'
			if (module is @orig.model and @dest.model.name not in @orig.model.dest) or
					(module is @dest.model and @orig.model.name not in @dest.model.orig)
				@_die()
		
		@setColor()

	# Gets called when a view is about to move (animated)
	#
	# @param view [Raphael] the view will be moving
	# @param dx [float] the amount to move in the x direction
	# @param dy [float] the amount to move in the y direction
	# @param dt [float] the amount of milliseconds for which to animate
	# @param ease [String] the easing transition being used
	#
	onViewMoving: ( view, dx, dy, dt, ease ) =>
		if view is @orig
			path = @_getPathString(dx, dy, 0, 0)
		else if view is @dest
			path = @_getPathString(0, 0, dx, dy)

		if path?
			@_contents?.stop()
			@_contents?.animate
				path: path
			, dt, ease

	# Gets called when a view has moved
	#
	# @param view [Raphael] the view which has moved
	#
	onViewMoved: ( module ) =>
		if module is @orig.model or module is @dest.model
			@draw()

	# Gets called when a view view was drawn
	#
	# @param view [Raphael] the view that was drawn
	#
	onViewDrawn: ( module ) =>
		if module is @orig.model or module is @dest.model
			@draw()



		
