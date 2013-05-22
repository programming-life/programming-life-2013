# Displays the properties of a module in a neat HTML popover
#
class View.ModuleProperties extends View.HTMLPopOver

	# Constructs a new ModuleProperties view.
	#
	# @param parent [View.Module] the accompanying module view
	# @param module [Model.Module] the module for which to display its properties
	# @param cellView [View.Cell] the accompanying cell view
	# @param cell [Model.Cell] the parent cell of the module
	# @param params [Object] options
	#
	constructor: ( parent, cellView, cell, module, params = {} ) ->
		@_cellView = cellView
		@_cell = cell
		@module = module

		@_changes = {}
		@_inputs = {}

		super parent, module.constructor.name, ' module-properties', 'bottom'
		
		@_bind('module.drawn', @, @onModuleDrawn)
		@_bind('module.set.hovered', @, @onModuleHovered)
		@_bind('module.set.selected', @, @onModuleSelected)
		@_bind('module.set.property', @, @onModuleInvalidated)
		
	# Create the popover header
	#
	# @return [Array<jQuery.Elem>] the header and the button element
	#
	_createHeader: ( ) ->
		@_header = $('<div class="popover-title"></div>')

		onclick = () => Model.EventManager.trigger( 'module.set.selected', @module, [ off ] )
		@_closeButton = $('<button class="close">&times;</button>')
		@_closeButton.on('click', onclick ) if onclick?
		
		@_header.append @title
		@_header.append @_closeButton
		return [ @_header, @_closeButton ]
		
	# Create the popover body
	#
	_createBody: () ->
		@_body = super
		@_drawForm()
		return @_body
		
	#  Create footer content and append to footer
	#
	# @param onclick [Function] the function to yield on click
	# @param saveText [String] the text on the save button
	# @return [Array<jQuery.Elem>] the footer and the button element
	#
	_createFooter: ( saveText = 'Save' ) ->
		@_footer = $('<div class="modal-footer"></div>')

		onclick = () => @_save()
		@_saveButton = $('<button class="btn btn-primary">' + saveText + '</button>')
		@_saveButton.on('click', onclick ) if onclick?

		@_footer.append @_saveButton
		return [ @_footer, @_saveButton ]

	# Populates the popover body with the required forms to reflect the module.
	#
	_drawForm: ( ) ->
		@_body.empty()
		form = $('<div class="form-horizontal"></div>')
		paramSection = $('<div></div>')
		metaboliteSection = $('<div></div>')
		metabolitesSection = $('<div></div>')
		enumSection = $('<div></div>')		

		properties = @module.metadata.properties
		properties.parameters.sort()

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

		for key in properties.metabolites ? []
			value = @module[key]

			input = @_drawInput('metabolites', key, value)
			metabolitesSection.append(input)

		if metabolitesSection.children().length > 0
			metabolitesSection.prepend('<hr />')

		form.append(metabolitesSection)

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
				text = value.split('#')[0]
				color = @_parent.hashColor(text)
				label = $('<span class="badge badge-metabolite">' + text + '</span>')
				label.css('background-color', color)
				controls.append(label)

			when 'metabolites'
				for v in value
					text = v.split('#')[0]
					color = @_parent.hashColor(text)					
					label = $('<span class="badge badge-metabolite">' + text + '</span> ')
					label.css('background-color', color)
					controls.append(label)

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
						@_changes[key] = parseInt event.target.value
					)
				) key			

		controlGroup.append controls
		return controlGroup


	# Saves all changed properties to the module.
	#
	_save: ( ) ->
		for key, value of @_changes
			console.log key, value
			@module[ key ] = value
		
		@_trigger( 'module.set.selected', @module, [ off ] )
		@_trigger( 'module.set.hovered', @module, [ off ] )
			
	# Gets called when a module view is drawn.
	#
	# @param module [Module] the module that is being drawn
	#
	onModuleDrawn: ( module ) ->
		if module is @module
			@setPosition()

	# Gets called when a module view selected.
	#
	# @param module [Module] the module that is being selected
	# @param selected [Boolean] the selection state of the module
	#
	onModuleSelected: ( module, selected ) ->
		if module is @module 
			if @_selected isnt selected
				@_setSelected selected 
		else if @_selected isnt off
			@_setSelected off

	# Gets called when a module view hovered.
	#
	# @param module [Module] the module that is being hovered
	# @param selected [Boolean] the hover state of the module
	#
	onModuleHovered: ( module, hovered ) ->
		if module is @module 
			if @_hovered isnt hovered
				@_setHovered hovered
		else if @_hovered isnt off
			@_setHovered off

	# Gets called when a module's parameters have changed
	#
	# @param module [Module] the module that has changed
	#
	onModuleInvalidated: ( module, prop ) ->
		if module is @module
			@_drawForm()