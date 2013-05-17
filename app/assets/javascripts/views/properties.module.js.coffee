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
	constructor: ( parent, cellView, cell, module, params = {} ) ->
		@_parent = parent
		@module = module
		@_cell = cell

		@_changes = {}
		@_inputs = {}

		@_allowEventBindings()
		@_bind('module.drawn', @, @onModuleDrawn)
		@_bind('module.set.hovered', @, @onModuleHovered)
		@_bind('module.set.selected', @, @onModuleSelected)
		@_bind('module.set.property', @, @onModuleInvalidated)

		@draw()

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

		@_elem.append @_createHeader()
		@_elem.append @_createBody()
		@_elem.append @_createFooter()		
		
		# Append popover to body
		$('body').append(@_elem)
		
	# Create the popover header
	#
	_createHeader: () ->
		@_header = $('<div class="popover-title"></div>')
		
		# Create closebutton and title and append to header
		closeButton = $('<button class="close">&times;</button>')
		closeButton.on('click', =>
			Model.EventManager.trigger('module.set.selected', @module, [ off ])
		)

		@_header.append @module.constructor.name
		@_header.append closeButton
		return @_header
		
	# Create the popover body
	#
	_createBody: () ->
		@_body = $('<div class="popover-content"></div>')
		@_drawForm()
		return @_body

	#  Create footer content and append to footer
	#
	_createFooter: () ->
		@_footer = $('<div class="modal-footer"></div>')

		@_saveButton = $('<button class="btn btn-primary">Save</button>')
		@_saveButton.on('click', =>
			@_save()
		)

		@_footer.append(@_saveButton)
		return @_footer

	# Populates the popover body with the required forms to reflect the module.
	#
	_drawForm: ( ) ->
		@_body.empty()
		form = $('<div class="form-horizontal"></div>')
		paramSection = $('<div></div>')
		metaboliteSection = $('<div></div>')
		enumSection = $('<div></div>')		

		properties = @module.metadata.properties

		for key in properties.parameters ? []
			value = @module[key]

			input = @_drawInput('parameter', key, value)			
			paramSection.append(input)

		form.append(paramSection)

		for key in properties.metabolite ? []
			value = @module[key]

			input = @_drawInput('metabolite', key, value)
			metaboliteSection.append(input)

		if metaboliteSection.children().length > 0
			metaboliteSection.prepend('<hr />')

		form.append(metaboliteSection)

		for enumeration in properties.enumerations ? []
			key = enumeration.name
			value = @module[key]
			params = {values: enumeration.values}

			input = @_drawInput('enumeration', key, value, params)
			enumSection.append(input)

		if enumSection.children().length > 0
			enumSection.prepend('<hr />')

		form.append(enumSection)

		@_body.append(form)

	_drawInput: ( type, key, value, params = {} ) ->
		id = @module.id + ':' + key
		keyLabel = key.replace(/_(.*)/g, "<sub>$1</sub>")

		controlGroup = $('<div class="control-group"></div>')
		controlGroup.append('<label class="control-label" for="' + id + '">' + keyLabel + '</label>')

		controls = $('<div class="controls"></div>')
		
		switch type
			when 'parameter'
				input = $('<input type="text" id="' + id + '" class="input-small" value="' + value + '" />')
				controls.append(input)

				((key) => 
					input.on('change', (event) => 
						@_changes[key] = parseFloat(event.target.value)
					)
				) key

			when 'metabolite'
				input = $('<input type="text" id="' + id + '" class="input-small" value="' + value + '" />')
				controls.append(input)

			when 'enumeration'
				select = $('<select id = "' + id + '" class="input-small"></select>')
				for k, v of params.values
					option = $('<option value="' + v + '">' + k + '</option>')
					if v is value
						option.attr('selected', true)
					select.append(option)
				controls.append(select)

				((key) => 
					select.on('change', (event) => 
						@_changes[key] = parseInt(event.target.value)
					)
				) key			

		controlGroup.append(controls)
		return controlGroup


	# Saves all changed properties to the module.
	#
	_save: ( ) ->
		for key, value of @_changes
			console.log key, value
			@module[key] = value

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
			console.log  -1 == "-1"
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
		if module is @module and @_parent.activated
			@setPosition()

	# Gets called when a module view selected.
	#
	# @param module [Module] the module that is being selected
	# @param selected [Boolean] the selection state of the module
	#
	onModuleSelected: ( module, selected ) ->
		if module is @module and @_parent.activated
			@_setSelected(selected)
		else
			@_setSelected(false)

	# Gets called when a module view hovered.
	#
	# @param module [Module] the module that is being hovered
	# @param selected [Boolean] the hover state of the module
	#
	onModuleHovered: ( module, hovered ) ->
		if module is @module and @_parent.activated
			@_setHovered(hovered)
		else
			@_setHovered(false)

	# Gets called when a module's parameters have changed
	#
	# @param module [Module] the module that has changed
	#
	onModuleInvalidated: ( module, prop ) ->
		if module is @module
			@_drawForm()

(exports ? this).View.ModuleProperties = View.ModuleProperties