# 
#
class View.HTMLPopOver extends Helper.Mixable

	@concern Mixin.EventBindings
	
	# Constructs a new ModuleProperties view.
	#
	# @param parent [Raphael] parent to hook on
	#
	constructor: ( parent ) ->
		@_parent = parent
		
		@_allowEventBindings()
		@draw()
		
	# Removes the properties' popover from the body
	#
	clear: ( ) ->
		@_elem?.remove()
		
	# Draws the properties popover
	#
	draw: ( ) ->
		@clear()
		
		@_elem = $('<div class="popover bottom module-properties"></div>')
		@_elem.append('<div class="arrow"></div>')

		[ header, button ] = @_createHeader()
		[ footer, button ] = @_createFooter()	
		
		@_elem.append header if header?
		@_elem.append @_createBody()
		@_elem.append footer if footer?	
		
		$('body').append @_elem
		
	# Create the popover header
	#
	_createHeader: ( onclick ) ->
		@_header = $('<div class="popover-title"></div>')

		@_closeButton = $('<button class="close">&times;</button>')
		@_closeButton.on('click', onclick ) if onclick?
		
		@_header.append @module.constructor.name
		@_header.append @_closeButton
		return [ @_header, @_closeButton ]
		
	# Create the popover body
	#
	_createBody: () ->
		@_body = $('<div class="popover-content"></div>')
		return @_body
		
	#  Create footer content and append to footer
	#
	_createFooter: ( onclick, saveText = 'Save' ) ->
		@_footer = $('<div class="modal-footer"></div>')

		@_saveButton = $('<button class="btn btn-primary">' + saveText + '</button>')
		@_saveButton.on('click', onclick ) if onclick?

		@_footer.append @_saveButton
		return [ @_footer, @_saveButton ]
		
	# Sets the position of the popover so the arrow points straight at the module view
	#
	setPosition: ( ) ->
		rect = @_parent.getBBox()
		x = rect.x + rect.width / 2
		y = rect.y + rect.height

		width = @_elem.width()
		left = x - width / 2
		top = y

		@_elem.css({left: left, top: top})

	# Sets wether or not the module is selected
	#
	# @param selected [Boolean] selection state
	#
	_setSelected: ( selected ) ->
		if selected
			@_setHovered(false)
			@_elem.addClass('selected')
		else
			@_elem.removeClass('selected')

		@_selected = selected

	# Sets wether or not the module is hovered
	#
	# @param hovered [Boolean] hover state
	#
	_setHovered: ( hovered ) ->
		if hovered and not @_selected
			@_elem.addClass('hovered')
		else
			@_elem.removeClass('hovered')

		@_hovered = hovered

		