# Provides an HTML Popover
#
# @concern Mixin.EventBindings
#
class View.HTMLPopOver extends Helper.Mixable

	@concern Mixin.EventBindings
	
	# Constructs a new HTML Popover view.
	#
	# @param parent [Raphael] parent to hook on
	# @param title [String] the title
	# @param classname [String] the classname
	# @param placement [String] the placement
	#
	constructor: ( @_parent , @title = '', classname = '', @placement = 'bottom' ) ->
		@_elem = @_create classname

		locationName = @placement[0].toUpperCase() + @placement.slice(1);
		@_location = View.Module.Location[locationName]

		@_allowEventBindings()
		@_bind('paper.resize', @, @setPosition)
		@_bind('module.view.drawn', @, @setPosition)
		@draw()
		
	# Creates the popover element
	#
	# @param classname [String] the additional classname
	# @return [jQuery.Elem] the popover element
	#
	_create: ( classname ) ->	
		elem = $('<div class="popover"></div>')
		elem.addClass(@placement).addClass(classname)
		$('body').append elem
		return elem
		
	# Kills the popover
	#
	kill: () ->
		@_elem?.remove()
		@_unbindAll()
		return this
		
	# Removes the properties' popover from the body
	#
	clear: ( ) ->
		@_elem?.empty()
		@_elem.append('<div class="arrow"></div>')
		return this
		
	# Draws the properties popover
	#
	draw: ( ) ->
		@clear()
		
		[ header, button ] = @_createHeader()
		[ footer, button ] = @_createFooter()	
		
		@_elem.append header if header?
		@_elem.append @_createBody()
		@_elem.append footer if footer?	
		
	# Nullifies the header
	#
	_createHeader: () ->	
		return [ undefined ]
		
	# Create the popover body
	#
	# @return [jQuery.Elem] the body element
	#
	_createBody: () ->
		@_body = $('<div class="popover-content"></div>')
		return @_body
		
	# Nullifies the footer
	#
	_createFooter: () ->
		return [ undefined ]
		
	# Sets the position of the popover so the arrow points straight at the model view
	#
	setPosition: ( ) ->

		if not @_parent.getAbsolutePoint?
			throw new TypeError( "Expected parent [#{@_parent?.constructor.name ? @_parent}] to have the getAbsolutePoint function." )
		
		[x, y] = @_parent.getAbsolutePoint(@_location)
		
		left = 0
		top = 0
		width = @_elem.width()
		height = @_elem.height()
		
		switch @placement
			when 'top'
				left = x - width / 2 - 1
				top = y - height - 4
			when 'bottom'
				left = x - width / 2 - 1
				top =  y
			when 'left'
				left = x - width - 4
				top = y - height / 2 - 1
			when 'right'
				left = x
				top = y - height / 2 - 1
				
		@_elem.css( { left: left, top: top } )
		return this

	# Sets wether or not the module is selected
	#
	# @param selected [Boolean] selection state
	#
	_setSelected: ( selected ) ->
		if selected isnt @_selected
			if selected
				@_setHovered off
				@_elem.addClass('selected')
			else
				@_elem.removeClass('selected')

		@_selected = selected
		return this

	# Sets wether or not the module is hovered
	#
	# @param hovered [Boolean] hover state
	#
	_setHovered: ( hovered ) ->
		if hovered isnt @_hovered 
			if hovered and not @_selected
				@_elem.addClass('hovered')
			else
				@_elem.removeClass('hovered')

		@_hovered = hovered
		return this