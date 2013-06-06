# Class to generate a view for a cell model
#
# @concern Mixin.EventBindings
#
class View.Cell extends View.RaphaelBase

	@concern Mixin.EventBindings
	@concern Mixin.DynamicProperties

	# Constructor for this view
	# 
	# @param paper [Raphael] paper parent
	# @param parent [View.RaphaelBase] base view
	# @param cell [Model.Cell] cell to view
	# @param interaction [Boolean] the interaction flag
	# 	
	constructor: ( paper, parent, cell, @_interaction = on ) ->
		super paper, parent
		
		@_drawn = []
		@viewsByType = {}
		@_splines = []

		@_width = @paper.width
		@_height = @paper.height
		
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
				return (_.flatten(_.map(@viewsByType, _.values))).concat(@_splines)

		@setter
			model: @setCell
		
	# Adds interaction to the cell
	#
	_addInteraction: () ->
		@_notificationsView = new View.CellNotification( @, @model )

	# Sets the displayed cell to value
	#
	# @param value [Model.Cell] the cell to display
	#
	setCell: ( value ) ->
			
		@kill()
		
		@_model = value
		for module in @_model._getModules()
			view = new View.Module( @paper, @, @_model, module, @_interaction )
			@add view
			@_drawn.push { model: module, view: view } 
		
		@_addInteraction() if @_interaction
		
		
		@_trigger( 'view.cell.set', @, [ @model ] )

		@redraw() if @x? and @y?
		return this
	
	# Kills the cell view by resetting itself and its children
	#
	kill: () ->
		super()
		
		@_notificationsView?.kill()
		
		@_drawn = []
		@viewsByType = {}
		
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
		#console.error "Adding view", view, @viewsByType
		type = view.getFullType()

		unless @viewsByType[type]?
			@viewsByType[type] = []

		dummies = _(@viewsByType[type]).filter( (v) -> v instanceof View.DummyModule)
		@viewsByType[type].push(view)
		@viewsByType[type] = _(@viewsByType[type]).difference(dummies).concat(dummies)
		view.draw()

	# Removes a view from the container
	#
	# @param [View.Base] The view to remove
	#
	remove: ( view ) ->
		type = view.getFullType()
		@viewsByType[type] = _( @viewsByType[type] ? [] ).without view

		view.kill()

	# Get module view for the given module
	#
	# @param module [Module] the module for which to return the view
	# @return [Module.View] the view which represents the given module
	#
	getView: ( module ) ->
		for type, views of @viewsByType
			view = _( views ).find( (view) -> view.model is module )
			if view?
				return view

	# Get module view by name
	#
	# @param name [String ] the module name for which to return the view
	# @return [Module.View] the view which represents the given module
	#
	getViewByName: ( name ) ->
		for type, views of @viewsByType
			console.log type, views
			view = _( views ).find( (view) -> view.model?.name is name )
			if view?
				return view

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
		@_shape = @paper.circle( @x, @y, @_radius )
		@_shape.insertBefore(@paper.bottom)
		$(@_shape.node).addClass('cell' )

		@_contents.push @_shape
		return @_shape

	# Returns the location for a module view
	#
	# @return [[float, float]] a type of the x and y coordinates
	#
	getViewPlacement: ( view ) ->
		type = view.getFullType()
		views = @viewsByType[type] ? []

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
	# @param module [Model.Module] module added
	#
	addModule: ( module ) =>
		unless ( _( @_drawn ).find( ( d ) -> d.model is module ) )?
			view = new View.Module( @paper, @, @model, module, @_interaction )
			@_drawn.push({view: view, model: module})
			@add view
			
	# On module removed, remove it from the cell
	# 
	# @param module [Model.Module] module removed
	#
	removeModule: ( module ) =>
		if ( drawn = _( @_drawn ).find( ( d ) -> d.model is module ) )?
			view = drawn.view.kill()				
			@_drawn = _( @_drawn ).without drawn
			@remove view

	# On spline added, add it to the cell and draw
	# 
	# @param spline [View.Spline] spline added
	#
	addSpline: ( spline ) =>
			if _(@_splines).find( ( s ) -> (s.orig is spline.orig and s.dest is spline.dest) )?
				spline.kill()
				return

			@_splines.push( spline )
			spline.draw()

	# On spline removed, remove it from the cell and kill it
	# 
	# @param spline [View.Spline] spline removed
	#
	removeSpline: ( spline ) =>
			@_splines = _( @_splines ).without spline
			spline.kill()
	
	# Creates or removes a preview view for a module
	#
	# @param source [Model.View] The source of the preview request
	# @param module [Model.Module] The module that needs to be previewed
	# @param selected [boolean] The selected state of the module view
	#
	previewModule: ( source, module, selected ) ->
		if source is @
			if selected
				preview = new View.ModulePreview( @_paper, @, @model, module, off )
				@_drawn.push({view: preview, model: module})
				@add preview
			else
				preview = @getView( module )
				if preview
					@remove preview
					@_trigger "module.preview.ended", preview
			return preview
