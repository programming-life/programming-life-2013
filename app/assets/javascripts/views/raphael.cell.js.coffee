# Class to generate a view for a cell model
#
# @concern Mixin.EventBindings
#
class View.Cell extends View.RaphaelBase

	@concern Mixin.EventBindings
	@concern Mixin.DynamicProperties

	@MAX_RUNTIME: 50

	# Constructor for this view
	# 
	# @param paper [Raphael] paper parent
	# @param parent [View.RaphaelBase] base view
	# @param cell [Model.Cell] cell to view
	#
	# 	
	constructor: ( paper, parent, cell, @_interaction = on ) ->
		super paper, parent
		
		@_drawn = []
		@_viewsByType = {}
		@_splines = []

		@_width = @_paper.width
		@_height = @_paper.height
		
		@_allowEventBindings()
		@_defineAccessors()
		@model = cell

		
	# Defines the accessors for this view
	#
	_defineAccessors: () ->

		@property
			_model:
				value: undefined
				configurable: false
				enumerable: false
				writable: true

		@getter
			model: ( ) ->
				return @_model
			_views: ( ) ->
				return (_.flatten(_.map(@_viewsByType, _.values))).concat(@_splines)

		@setter
			model: @setCell
		
	# Adds interaction to the cell
	#
	_addInteraction: () ->
		@_createButtons()
		@_notificationsView = new View.CellNotification( @, @model )

	# Sets the displayed cell to value
	#
	# @param value [Model.Cell] the cell to display
	#
	setCell: ( value ) ->
			
		@kill()
		
		@_model = value
		for module in @_model._getModules()
			view = new View.Module( @_paper, @, @_model, module, @_interaction )
			@add view
			@_drawn.push { model: module, view: view } 
		
		@_addInteraction() if @_interaction
		@_bind( 'cell.module.add', @, @onModuleAdd )		
		@_bind( 'cell.module.remove', @, @onModuleRemove )
		@_bind( 'cell.metabolite.add', @, @onModuleAdd )
		@_bind( 'cell.metabolite.remove', @, @onModuleRemove )
		@_bind( 'cell.spline.add', @, @onSplineAdd)
		@_bind( 'cell.spline.remove', @, @onSplineRemove)
		
		@_trigger( 'view.cell.set', @, [ @model ] )

		@redraw() if @x? and @y?
		return this
	
	# Kills the cell view by resetting itself and its children
	#
	kill: () ->
		super()
		
		@_notificationsView?.kill()
		
		@_drawn = []
		@_viewsByType = {}
		
	# Creates the interaction buttons
	# 
	_createButtons: () ->
		
		@add new View.DummyModule( @_paper, @, @model, Model.CellGrowth, 1 )
		@add new View.DummyModule( @_paper, @, @model, Model.DNA, 1 )
		@add new View.DummyModule( @_paper, @, @model, Model.Lipid, 1 )
		@add new View.DummyModule( @_paper, @, @model, Model.Metabolite, -1, { placement: Model.Metabolite.Outside, type: Model.Metabolite.Substrate, amount: 0, supply: 1 } )
		@add new View.DummyModule( @_paper, @, @model, Model.Metabolite, -1, { placement: Model.Metabolite.Inside, type: Model.Metabolite.Product, amount: 0, supply: 0 } )
		@add new View.DummyModule( @_paper, @, @model, Model.Transporter, -1, { direction: Model.Transporter.Inward } )
		@add new View.DummyModule( @_paper, @, @model, Model.Metabolism, -1 )
		@add new View.DummyModule( @_paper, @, @model, Model.Protein, -1 )
		@add new View.DummyModule( @_paper, @, @model, Model.Transporter, -1, { direction: Model.Transporter.Outward } )

	# Returns the bounding box of this view
	#
	# @return [Object] a bounding box object with coordinates
	#
	getBBox: ( ) -> 
		return @_shape?.getBBox() ? { x:0, y:0, x2:0, y2:0, width:0, height:0 }

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

	#
	#
	getAbsolutePoint: ( location ) ->
		[x, y] = @getPoint(location)
		return @getAbsoluteCoords(x, y)

	# Add a view to draw in the container
	#
	# @param view [View.Base] The view to add
	#
	add: ( view ) ->
		type = view.getFullType()

		unless @_viewsByType[type]?
			@_viewsByType[type] = []

		dummies = _(@_viewsByType[type]).filter( (v) -> v instanceof View.DummyModule)
		@_viewsByType[type].push(view)
		@_viewsByType[type] = _(@_viewsByType[type]).difference(dummies).concat(dummies)
		view.draw()

	# Removes a view from the container
	#
	# @param [View.Base] The view to remove
	#
	remove: ( view ) ->
		type = view.getFullType()
		@_viewsByType[type] = _( @_viewsByType[type] ).without view

		view.kill()

	# Get module view for the given module
	#
	# @param module [Module] the module for which to return the view
	# @return [Module.View] the view which represents the given module
	#
	getView: ( module ) ->
		return _( @_drawn ).find( ( d ) -> d.model is module )?.view

	# Draws the cell
	#
	# @param x [Integer] x location
	# @param y [Integer] y location
	#
	draw: (  x = 0, y = 0, @_radius = 400 ) ->
		super(x, y)

		@_drawCell()
		
	# Redraws the cell
	# 		
	redraw: () ->
		@draw( @x, @y )	
		
	# Draws the cell on coordinates
	# 
	# @param x [Integer] the center x position
	# @param y [Integer] the center y position
	# @param radius [Integer] radius of the cell
	# @return [Raphael] the cell shape
	#
	_drawCell: ( ) ->
		@_shape = @_paper.circle( @x, @y, @_radius )
		@_shape.insertBefore(@_paper.bottom)
		$(@_shape.node).addClass('cell' )

		@_contents.push @_shape
		return @_shape

	# Returns the location for a module view
	#
	# @return [[float, float]] a type of the x and y coordinates
	#
	getViewPlacement: ( view ) ->
		type = view.getFullType()
		views = @_viewsByType[type]

		index = views.indexOf(view)
		
		switch type
		
			when "CellGrowth"
				alpha = -3 * Math.PI / 4 + ( ( index + 1 ) * Math.PI / 12 )
				x = @x + @_radius * Math.cos( alpha )
				y = @y + @_radius * Math.sin( alpha )
			
			when "Lipid"
				alpha = -3 * Math.PI / 4 + ( index * Math.PI / 12 )
				x = @x + @_radius * Math.cos( alpha )
				y = @y + @_radius * Math.sin( alpha )

			when "Transporter-inward"
				dx = 80 * index				
				alpha = Math.PI - Math.asin( dx / @_radius )
				x = @x + @_radius * Math.cos( alpha )
				y = @y + @_radius * Math.sin( alpha )

			when "Transporter-outward"
				dx = 80 * index	
				alpha = Math.asin( dx / @_radius )
				x = @x + @_radius * Math.cos( alpha )
				y = @y + @_radius * Math.sin( alpha )

			when "DNA"
				x = @x + ( index % 3 * 40 )
				y = @y - @_radius / 2 + ( Math.floor( index / 3 ) * 40 )

			when "Metabolism"
				x = @x + ( index % 2 * 130 )
				y = @y + @_radius / 2 + ( Math.floor( index / 2 ) * 60 )

			when "Protein"
				x = @x + @_radius / 2 + ( index % 3 * 40 )
				y = @y - @_radius / 2 + ( Math.floor( index / 3 ) * 40 )
				
			when "Metabolite-substrate-inside"
				x = @x - 200
				y = @y + index * 80

			when "Metabolite-product-inside"
				x = @x + 200
				y = @y + index * 80

			when "Metabolite-substrate-outside"
				x = @x - @_radius - 200
				y = @y + index * 80

			when "Metabolite-product-outside"
				x = @x + @_radius + 200
				y = @y + index * 80

		return [x, y]
	
	# On module added, add it to the cell
	# 
	# @param cell [Model.Cell] cell added to
	# @param module [Model.Module] module added
	#
	onModuleAdd: ( cell, module ) =>
		if cell is @model
			unless ( _( @_drawn ).find( ( d ) -> d.model is module ) )?
				view = new View.Module( @_paper, @, @model, module, @_interaction )
				@_drawn.push({view: view, model: module})
				@add view		
			
	# On module removed, removed it from the cell
	# 
	# @param cell [Model.Cell] cell removed from
	# @param module [Model.Module] module removed
	#
	onModuleRemove: ( cell, module ) =>
		if cell is @model
			if ( drawn = _( @_drawn ).find( ( d ) -> d.model is module ) )?
				view = drawn.view.kill()				
				@_drawn = _( @_drawn ).without drawn
				@remove view

	# On spline added, add it to the cell and draw
	# 
	# @param cell [Model.Cell] cell added to
	# @param spline [View.Spline] spline added
	#
	onSplineAdd: ( cell, spline ) =>
		if cell is @model
			if _(@_splines).find( ( s ) -> (s.orig is spline.orig and s.dest is spline.dest) )?
				spline.kill()
				return

			@_splines.push( spline )
			spline.draw()

	# On spline removed, remove it from the cell and kill it
	# 
	# @param cell [Model.Cell] cell removed from
	# @param spline [View.Spline] spline removed
	#
	onSplineRemove: ( cell, spline ) =>
		if cell is @model
			@_splines = _( @_splines ).without spline
			spline.kill()
	
	# Creates or removes a preview view for a module
	#
	# @param source [Model.View] The source of the preview request
	# @param module [Model.Module] The module that needs to be previewed
	# @param selected [boolean] The selected state of the module view
	#
	previewModule: ( source, module, selected ) ->
		type = source.getFullType()
		if source in @_viewsByType[type]
			if selected
				preview = new View.ModulePreview( @_paper, @, @model, module, off )
				@_drawn.push({view: preview, model: module})
				@add preview
			else
				preview = @getView( module )
				if preview
					@remove preview
