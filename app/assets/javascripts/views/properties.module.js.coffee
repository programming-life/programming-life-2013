# Class View.ModuleProperties
#
# Displays the properties of a module in a neat HTML popover
#
class View.ModuleProperties extends Helper.Mixable
	@concern Mixin.EventBindings

	# Constructs a new ModuleProperties view.
	#
	# @param view [Module.View] the accompanying module view
	# @param module [Module] the module for which to display its properties
	# @param cell [Cell] the parent cell of the module
	#
	constructor: ( view, module, cell ) ->
		@_view = view
		@module = module
		@_cell = cell		

		@_allowEventBindings()
		@_bind('module.drawn', @, @onModuleDrawn)
		@_bind('module.set.hovered', @, @onModuleHovered)
		@_bind('module.set.selected', @, @onModuleSelected)
		@_bind('module.set.property', @, @onModuleInvalidated)

		@draw()

		console.log @module._dynamicProperties

	# Removes the properties' popover from the body
	#
	clear: ( ) ->
		@_elem?.remove()

	# Draws the properties popover
	#
	draw: ( ) ->
		@clear()

		# Create the popover
		@_elem = $('<div class="popover bottom module-properties"></div>')
		@_elem.append('<div class="arrow"></div>')

		# Create the popover header
		@_header = $('<div class="popover-title"></div>')
		@_elem.append(@_header)

		# Create closebutton and title and append to header
		closeButton = $('<button class="close">&times;</button>')
		closeButton.on('click', =>
			Model.EventManager.trigger('module.set.selected', @module, [ off ])
		)

		@_header.append(@module.constructor.name)
		@_header.append(closeButton)

		# Create the popover body
		@_body = $('<div class="popover-content"></div>')
		@_elem.append(@_body)

		form = $('<div class="form-horizontal"></div>')

		# Create body content and append to body
		for prop in @module._dynamicProperties
			propLabel = prop.replace(/_(.*)/g, "<sub>$1</sub>")

			controlGroup = $('<div class="control-group"></div>')
			controlGroup.append('<label class="control-label">' + propLabel + '</label>')

			controls = $('<div class="controls"></div>')
			controls.append('<input class="input-mini" type="text" value="' + @module[prop] + '" />')
			controlGroup.append(controls)
			form.append(controlGroup)

		@_body.append(form)

		# Create the popover footer
		@_footer = $('<div class="modal-footer"></div>')
		@_elem.append(@_footer)		

		# Create footer content and append to footer
		@_footer.append('<button class="btn">Done</button>')

		# Append popover to body
		$('body').append(@_elem)

	# Sets the position of the popover so the arrow points straight at the module view
	#
	setPosition: ( x, y ) ->
		rect = @_view.getBBox()
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

	# Gets called when a module view is drawn.
	#
	# @param module [Module] the module that is being drawn
	#
	onModuleDrawn: ( module ) ->
		if module is @module and @_view.activated
			@setPosition()

	# Gets called when a module view selected.
	#
	# @param module [Module] the module that is being selected
	# @param selected [Boolean] the selection state of the module
	#
	onModuleSelected: ( module, selected ) ->
		if module is @module and @_view.activated
			@_setSelected(selected)
		else
			@_setSelected(false)

	# Gets called when a module view hovered.
	#
	# @param module [Module] the module that is being hovered
	# @param selected [Boolean] the hover state of the module
	#
	onModuleHovered: ( module, hovered ) ->
		if module is @module and @_view.activated
			@_setHovered(hovered)
		else
			@_setHovered(false)

	# Gets called when a module's parameters have changed
	#
	# @param module [Module] the module that has changed
	#
	onModuleInvalidated: ( module ) ->

(exports ? this).View.ModuleProperties = View.ModuleProperties