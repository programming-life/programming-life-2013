# Provides an HTML Popover
#
# @concern Mixin.EventBindings
#
class View.HTMLPopOver extends Helper.Mixable

	@concern Mixin.EventBindings
	
	# Constructs a new ModuleProperties view.
	#
	# @param parent [Raphael] parent to hook on
	# @param title [String] the title
	# @param classname [String] the classname
	# @param placement [String] the placement
	#
	constructor: ( parent, @title = '', classname = '', @placement = 'bottom' ) ->
		@_parent = parent
		
		@_elem = @_create( classname )
		
		@_allowEventBindings()
		@draw()
		
	# Creates the popover element
	#
	# @param classname [String] the additional classname
	# @return [jQuery.Elem] the popover element
	#
	_create: ( classname ) ->	
		elem = $('<div class="popover ' + @placement + ' ' + classname + '"></div>')
		$('body').append elem
		return elem
		
	# Kills the popover
	#
	kill: () ->
		@elem?.remove()
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
		
	# Sets the position of the popover so the arrow points straight at the module view
	#
	setPosition: ( ) ->
	
		rect = @_parent.getBBox()
		cx = rect.x + rect.width / 2
		cy = rect.y + rect.height / 2

		width = @_elem.width()
		height = @_elem.height()
		
		switch @placement
			when 'top'
				left = cx - width / 2 - 1
				top = rect.y - height - 6
			when 'bottom'
				left = cx - width / 2 
				top =  rect.y + rect.height + 2
			when 'left'
				left = rect.x - width - 4
				top = cy - height / 2
			when 'right'
				left = rect.x + rect.width + 2
				top = cy - height / 2
				
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