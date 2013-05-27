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

		@_compounds = @_cell.getCompoundNames()
		@_metabolites = @_cell.getMetaboliteNames()
		@_selectables = []

		super parent, module.constructor.name, ' module-properties', 'bottom'
		
		@_bind('module.hovered.changed', @, @onModuleHovered)
		@_bind('module.selected.changed', @, @onModuleSelected)
		@_bind('module.property.changed', @, @onModuleInvalidated)

		@_bind('cell.module.added', @, @onCompoundsChanged)
		@_bind('cell.module.removed', @, @onCompoundsChanged)
		@_bind('cell.metabolite.added', @, @onMetabolitesChanged)
		@_bind('cell.metabolite.removed', @, @onMetabolitesChanged)
		
		@_setSelected off
		
	# Gets the id for this popover
	#
	getFormId: () ->
		return 'properties-form-' + Model.Module.extractId( @module.id ).id	
		
	# Create the popover header
	#
	# @return [Array<jQuery.Elem>] the header and the button element
	#
	_createHeader: ( ) ->
		@_header = $('<div class="popover-title"></div>')

		onclick = () => Model.EventManager.trigger( 'module.selected.changed', @module, [ off ] )
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
	_createFooter: ( removeText = 'Remove', saveText = 'Save' ) ->
		@_footer = $('<div class="modal-footer"></div>')

		remove = () => @_remove()
		@_removeButton = $('<button class="btn btn-danger">' + removeText + '</button>')
		@_removeButton.on('click', remove ) if remove?

		save = () => @_save()
		@_saveButton = $('<button class="btn btn-primary">' + saveText + '</button>')
		@_saveButton.on('click', save ) if save?

	
		@_footer.append @_removeButton
		@_footer.append @_saveButton
		return [ @_footer, @_removeButton, @_saveButton ]
		
	# Draws a certain property
	#
	# @param key [String] property
	# @param type [String] property type
	# @param params [Object] additional parameters
	# @return [jQuery.elem] elements
	#
	_drawProperty: ( key, type, params = {} ) ->
		value = @module[ key ]
		return @_drawInput( type, key, value, params )			

	# Populates the popover body with the required forms to reflect the module.
	#
	_drawForm: ( ) ->
		
		form = $('<div class="form-horizontal" id="' + @getFormId() + '"></div>')
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
	# @param key [String] property
	# @param type [String] property type
	# @param value [any] the property value
	# @param params [Object] additional parameters
	# @return [jQuery.elem] elements
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
				controls.append @_drawParameter( id, key, value )

			when 'metabolites'
				controls.append @_drawMetabolite( id, key, v ) for v in value
				controls.append @_drawSelectionFor( type, drawtype, id, key, value )
					
			when 'dna'
				controls.append @_drawDNA( id, key, value )
			
			when 'compounds'
				controls.append @_drawCompound( id, key, v ) for v in value
				controls.append @_drawSelectionFor( type, drawtype, id, key, value )

			when 'enumeration'
				controls.append @_drawEnumeration( id, key, value, params )

		controlGroup.append controls
		return controlGroup
	
	# Draws the input for a parameter
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	_drawParameter: ( id, key, value ) ->
		input = $('<input type="text" id="' + id + '" class="input-small" value="' + value + '" />')
		@_bindOnChange( key, input )
		return input
				
	# Draws the input for a metabolite
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	_drawMetabolite: ( id, key, value ) ->
		text = value.split( '#' )[0]
		color = @_parent.hashColor text				
		label = $('<span class="badge badge-metabolite" data-selectable-value="' + key + '">' + text + '</span> ')
		label.css( 'background-color', color )
		return label
	
	# Draws the input for DNA
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	_drawDNA: ( id, key, value ) ->
		return $('<span class="badge badge-important">' + value + '</span> ')
		
	# Draws the input for a compound
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	_drawCompound: ( id, key, value ) ->
		return $('<span class="badge" style="margin-right: 3px;" data-selectable-value="' + key + '">' + value + '</span>')
		
	# Draws the input for an enumeration
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	# @todo on clear/kill remove property from option
	#
	_drawEnumeration: ( id, key, value, params ) ->
		select = $('<select id = "' + id + '" class="input-small"></select>')
		for k, v of params.values
			option = $('<option value="' + v + '">' + k + '</option>')
			option.prop( 'selected', true ) if v is value
			select.append option
			
		@_bindOnChange( key, select )
		return select
		
	# Binds an on change event to the given input that sets the key
	#
	# @param key [String] property to set
	# @param input [jQuery.Elem] the element to set it on
	# 
	_bindOnChange: ( key, input ) ->
		((key) => 
			input.on('change', (event) => 
				value = event.target.value
				value = parseFloat value unless isNaN value
				@_changes[ key ] = value
			)
		) key
		
	# Binds an on change event to a selectable input that sets the key
	#
	# @param key [String] property to set
	# @param selectable [jQuery.Elem] the selectable to set it on
	# 
	_bindOnSelectableChange: ( key, selectable ) ->
		((key) => 
			selectable.on('change', (event) => 
				value = event.target.value
				if ( selectable.closest('[data-multiple]').data( 'multiple' ) is on )
					@_changes[ key ] = _( @module[ key ] ).clone( true ) unless @_changes[ key ]
					if event.target.checked
						@_changes[ key ].push value
					else
						@_changes[ key ] = _( @_changes[ key ] ).without value
				else
					@_changes[ key ] = value
			)
		) key
		
	# Draws the selectable selection for
	#
	# @param type [String] the paramater type
	# @param drawtype [String] the drawing paramter type
	# @param value [String, Array<String> current value
	# @return [jQuery.Elem] element
	#
	_drawSelectionFor: ( type, drawtype, id, key, value ) ->
		multiple = /s$/.test type
		container = $( "<div data-selectable='#{key}' data-multiple='#{multiple}'></div>" )
		
		inputname = if multiple then id + '[]' else id
		inputtype = if multiple then 'checkbox' else 'radio'

		selectable =
			container: container
			name: inputname
			type: inputtype
			drawtype: drawtype
			key: key
			id: id
			value: () => @module[ key ]
			
		@_selectables.push selectable
		@_drawSelectable selectable

		return container
		
	# Draws a selectable
	#
	# @param selectable [Object] the selectable object
	#
	_drawSelectable: ( selectable ) -> 
		options = switch selectable.drawtype
			when 'metabolites'
				@_metabolites
			when 'compounds'
				@_compounds
				
		values = _( selectable.value() )
		options = _( options )
		options = _( options.map( ( v ) -> v.split('#')[0] ) ) if selectable.key is 'transported'
		options = _( options.filter( ( v ) -> not /#ext$/.test v ) )
		
		for option in _( options.concat values.value() ).uniq()
			
			label = $( "<label class='option-selectable #{selectable.type}' for='#{selectable.id}-#{option}'></label>" )
			elem = $( "<input type='#{selectable.type}' name='#{selectable.name}' id='#{selectable.id}-#{option}' value='#{option}'>" )
			elem.prop( 'checked', values.contains(option) )
			@_bindOnSelectableChange( selectable.key, elem )
			
			display_name = option.replace( /#(.*)/, '' )
			labeltext = $("<span class='badge #{if !options.contains(option) then 'unknown' else ''}'>#{display_name}</span>")
			label.append elem
			label.append labeltext 
			selectable.container.append label
			
		return selectable
			
	# Redraws a selectable
	# 
	# @param selectable [Object] selectable object
	#
	_redrawSelectable: ( selectable ) ->
		selectable.container.empty()
		@_drawSelectable( selectable )
		
	# Sets all visibilities of all selectables
	#
	# @param selected [Boolean] is selected flag
	#
	_setSelectablesVisibility: ( selected ) ->
		@_getThisForm()
			.find( '[data-selectable-value]' )
			.css( 'display', if selected then 'none' else 'inline-block' )
			
		@_getThisForm()
			.find( '[data-selectable]' )
			.css( 'display', if selected then 'inline-block' else 'none' )
		
	# Gets this form element
	#
	# @return [jQuery.Elem]
	#
	_getThisForm: () ->
		return $( "##{@getFormId()}" )
		
	# Sets the selection state of this popover
	# 
	# @param selected [Boolean] the selection state
	#
	_setSelected: ( selected ) ->
		super selected
		
		@_getThisForm()
			.find( 'input, select' )
			.prop( 'disabled', !selected )
			
		@_setSelectablesVisibility( selected )

	# Saves all changed properties to the module.
	#
	_save: ( ) ->
	
		for key, value of @_changes
			@module[ key ] = value
			
		@_changes = {}
		@_trigger( 'module.selected.changed', @module, [ off ] )
		@_trigger( 'module.hovered.changed', @module, [ off ] )
	

	_remove: ( ) ->
	
		@_cell.remove(@module)


			
	# Runs when a compound is changed (added/removed)
	#
	# @param cell [Model.Cell] changed on
	# @param module [Model.Module] the changed compound
	#
	onCompoundsChanged: ( cell, module ) ->
		return if cell isnt @_cell
		@_compounds = @_cell.getCompoundNames()
		@_redrawSelectable( selectable ) for selectable in @_selectables
	
	# Runs when a metabolite is changed (added/removed)
	#
	# @param cell [Model.Cell] changed on
	# @param module [Model.Metabolite] the changed metabolite
	#
	onMetabolitesChanged: ( cell, module ) ->
		return if cell isnt @_cell
		@_metabolites = @_cell.getMetaboliteNames()
		@_redrawSelectable( selectable ) for selectable in @_selectables
			
	# Gets called when a module view is drawn.
	#
	# @param module [Module] the module that is being drawn
	#
	onModuleDrawn: ( module ) ->
		@setPosition() if module is @module

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
	onModuleInvalidated: ( module, action ) ->
		if module is @module
			@_body?.empty()
			@_selectables = []
			@_drawForm()
			