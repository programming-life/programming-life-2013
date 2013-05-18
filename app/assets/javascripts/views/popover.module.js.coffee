# Class View.ModuleProperties
#
# Displays the properties of a module in a neat HTML popover
#
class View.ModuleProperties extends View.HTMLPopOver

	# Constructs a new ModuleProperties view.
	#
	# @param view [Module.View] the accompanying module view
	# @param module [Module] the module for which to display its properties
	# @param cell [Cell] the parent cell of the module
	#
	constructor: ( parent, cellView, cell, module, params = {} ) ->
		@_cellView = cellView
		@_cell = cell
		@module = module

		@_changes = {}
		@_inputs = {}

		super parent
		
		@_bind('module.drawn', @, @onModuleDrawn)
		@_bind('module.set.hovered', @, @onModuleHovered)
		@_bind('module.set.selected', @, @onModuleSelected)
		@_bind('module.set.property', @, @onModuleInvalidated)
		
	# Create the popover header
	#
	_createHeader: ( ) ->
		onclick = () => Model.EventManager.trigger('module.set.selected', @module, [ off ])
		return super onclick
		
	# Create the popover body
	#
	_createBody: () ->
		@_body = super
		@_drawForm()
		return @_body

	#  Create footer content and append to footer
	#
	_createFooter: () ->
		onclick = () => @_save()
		return super onclick

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
			@module[key] = value
		
		@_trigger( 'module.set.selected', @module, [ off ] )
			
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
		if module is @module 
			if @_parent.activated and @_selected isnt selected
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
			if @_parent.activated and @_hovered isnt hovered
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

(exports ? this).View.ModuleProperties = View.ModuleProperties