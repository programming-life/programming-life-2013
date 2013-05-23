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
		
	#
	#
	#
	_drawProperty: ( key, type, params = {} ) ->
		value = @module[ key ]
		return @_drawInput( type, key, value, params )			
		

	# Populates the popover body with the required forms to reflect the module.
	#
	_drawForm: ( ) ->
		@_body.empty()
		form = $('<div class="form-horizontal properties-form-' + Model.Module.extractId( @module.id ).id + '"></div>')
		sections = []

		properties = @module.metadata.properties
		properties.parameters?.sort()

		iteration = 
			parameter: 'parameters'
			metabolite: 'metabolite'
			metabolites: 'metabolites' 
			compound: 'compound'
			compounds: 'compounds'
			dna: 'dna'
			
		for type, prop of iteration
			continue unless properties[ prop ]?
			sections.push ( section = $( '<div class="' + type + '"></div>' ) )
			section.prepend( '<hr />' ) if sections.length > 1
			for key in properties[ prop ]
				section.append @_drawProperty( key, type )
	
		if properties.enumerations
			sections.push ( section = $( '<div class="enumeration"></div>' ) )
			section.prepend( '<hr />' ) if sections.length > 1
			for enumeration in properties.enumerations ? []
				section.append @_drawProperty( enumeration.name, 'enumeration', {values: enumeration.values} )

		for section in sections
			form.append section

		@_body.append form

	# Draws input 
	#
	_drawInput: ( type, key, value, params = {} ) ->
		id = 'property-' + Model.Module.extractId( @module.id ).id + '-' + key
		keyLabel = key.replace(/_(.*)/g, "<sub>$1</sub>")

		controlGroup = $('<div class="control-group"></div>')
		controlGroup.append('<label class="control-label" for="' + id + '">' + keyLabel + '</label>')

		controls = $('<div class="controls"></div>')
		
		drawtype = type
		if drawtype is 'metabolite' or drawtype is 'compound'
			value = [ value ]
			drawtype += 's'
			
		switch drawtype
			when 'parameter'
				input = $('<input type="text" id="' + id + '" class="input-small" value="' + value + '" />')
				controls.append(input)

				((key) => 
					input.on('change', (event) => 
						@_changes[key] = parseFloat(event.target.value)
					)
				) key

			when 'metabolites'
				for v in value
					text = v.split('#')[0]
					color = @_parent.hashColor(text)					
					label = $('<span class="badge badge-metabolite">' + text + '</span> ')
					label.css('background-color', color)
					controls.append(label)
					
			when 'dna'
				label = $('<span>' + value + '</span> ')
				controls.append(label)
			
			when 'compounds'
				for v in value
					label = $('<span>' + v + ' </span>')
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

	#
	#
	_setSelected: ( selected ) ->
		super selected
		$( '.properties-form-' + Model.Module.extractId( @module.id ).id ).find( 'input, select' ).attr( 'disabled', !selected )

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