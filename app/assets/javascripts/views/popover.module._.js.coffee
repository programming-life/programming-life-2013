# Displays the properties of a module in a neat HTML popover
#
# @concern Mixin.Catcher
#
class View.ModuleProperties extends View.HTMLPopOver

	@concern Mixin.Catcher

	# Constructs a new ModuleProperties view.
	#
	# @param parent [View.Module] the accompanying module view
	# @param module [Model.Module] the module for which to display its properties
	# @param cellView [View.Cell] the accompanying cell view
	# @param cell [Model.Cell] the parent cell of the module
	#
	constructor: ( parent, @_cellView, @_cell, @module, @_preview ) ->
		@_changes = {}

		@_compounds = @_cell.getCompoundNames()
		@_metabolites = @_cell.getMetaboliteNames()
		@_selectables = []

		super parent, module.constructor.name, 'module-properties', 'bottom'
		
		@_bind('module.property.changed', @, @_onModuleInvalidated)
		@_bind('module.compound.changed', @, @_onModuleInvalidated)

		@_bind('cell.module.added', @, @_onCompoundsChanged)
		@_bind('cell.module.removed', @, @_onCompoundsChanged)
		@_bind('cell.metabolite.added', @, @_onMetabolitesChanged)
		@_bind('cell.metabolite.removed', @, @_onMetabolitesChanged)
		
	# Gets the id for this popover
	#
	getFormId: () ->
		return 'properties-form-' + Model.Module.extractId( @module.id ).id	

	# Gets the id for an input with a certain key
	#
	# @param key [String] the key for which to get the id
	#
	getInputId: ( key ) ->
		return 'property-' + Model.Module.extractId( @module.id ).id + '-' + key
		
	# Create the popover header
	#
	# @return [Array<jQuery.Elem>] the header and the button element
	#
	_createHeader: ( ) ->
		@_header = $('<div class="popover-title"></div>')

		@_closeButton = $('<button class="close">&times;</button>')
		@_closeButton.on('click', @_close )
		
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
	_createFooter: ( removeText = '<i class="icon-trash icon-white"></i>', saveText ) ->
		@_footer = $('<div class="modal-footer"></div>')

		@_removeButton = $('<button class="btn btn-danger pull-left">' + removeText + '</button>')
		@_removeButton.on('click', @_remove )

		unless saveText?
			saveText = if @_preview
					'<i class=" icon-ok icon-white"></i> Create'
				else
					'<i class=" icon-ok icon-white"></i> Save'
		
		@_saveButton = $('<button class="btn btn-primary">' + saveText + '</button>')
		@_saveButton.click @_save

		@_footer.append @_removeButton unless @_preview
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
		@_currents[ key ] = value
		return @_drawInput( type, key, value, params )			

	# Populates the popover body with the required forms to reflect the module.
	#
	_drawForm: ( ) ->
		@_currents = {}
		
		form = $('<form class="form-horizontal" id="' + @getFormId() + '"></form>')
		sections = []

		properties = @_getModuleProperties()
		properties.parameters?.sort()
		properties.name = ['name']

		iteration = 
			name: 'name'
			parameter: 'parameters'
			metabolite: 'metabolite'
			metabolites: 'metabolites' 
			compound: 'compound'
			compounds: 'compounds'
			dna: 'dna'
			population: 'cell'
			
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

		form.find('input[type=text]').click( ( e ) ->
			$(@).select()
		)

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
		id = @getInputId(key)
		keyLabel = key.replace(/_(.*)/g, "<sub>$1</sub>")
		keyLabel = type if key is 'cell'

		controlGroup = $('<div class="control-group"></div>')
		controlGroup.append('<label class="control-label" for="' + id + '">' + keyLabel + '</label>')

		controls = $('<div class="controls"></div>')
	
		drawtype = type
		if drawtype is 'metabolite' or drawtype is 'compound'
			value =  if value? then [ value ] else ['']
			drawtype += 's'
			
		unless value?
			value = if key in [ 'dna', 'cell' ] then [ key ] else []
			
		switch drawtype
			when 'name'
				controls.append @_drawName( id, key, value )
			when 'parameter'
				controls.append @_drawParameter( id, key, value )
			when 'metabolites'
				controls.append @_drawSelectionFor( type, drawtype, id, key, value )
			when 'dna'
				controls.append @_drawDNA( id, key, value )
			when 'population'
				controls.append @_drawPopulation( id, key, value )
			when 'compounds'
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
	_drawName: ( id, key, value ) ->
		input = $('<input disabled type="text" id="' + id + '" class="input-small disabled" data-multiple="false" value="' + value + '" />')
		@_bindOnChange( key, input )
		input.removeClass( 'disabled' ) if @_preview
		return input
	
	# Draws the input for a parameter
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	_drawParameter: ( id, key, value ) ->
		input = $('<input required type="number" step="0.001" id="' + id + '" class="input-small" value="' + value + '" />')
		@_bindOnChange( key, input )
		return input
				
	# Draws the input for a metabolite
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	_drawMetabolite: ( id, key, value ) ->
		text = value?.split( '#' )[0]
		color = @::hashColor text				
		label = $('<div class="badge badge-metabolite" data-selectable-value="' + key + '">' + text + '</div> ')
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
		
	# Draws the input for Cell (Growth)
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	_drawPopulation: ( id, key, value ) ->
		return $('<span class="badge badge-inverse">' + value + '</span> ')
		
	# Draws the input for a compound
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	_drawCompound: ( id, key, value ) ->
		return $('<div class="checkbox"  data-selectable-value="' + key + '"><span class="badge" style="margin-right: 3px;">' + value + '</span></div>')
		
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
			option.attr( 'selected', true ) if v is value
			select.append option
			
		@_bindOnChange( key, select )
		if key is 'placement' or key is 'direction'
			select.prop( 'disabled', true )
			select.addClass( 'disabled' )
		return select
		
	# Binds an on change event to the given input that sets the key
	#
	# @param key [String] property to set
	# @param input [jQuery.Elem] the element to set it on
	# 
	_bindOnChange: ( key, input ) ->

		((key) =>
		
			onchange = (event) => 
				value = event.target.value
				if value.length == 0
					@_changes[ key ] = undefined
					value = undefined
				else
					value = parseFloat value unless isNaN value

				@_changes[ key ] = value
				@_triggerChange( key, value )
				
			input.on( 'change', onchange )
				.on( 'keyup', onchange )
		) key
		
	# Gets the current value for this key
	#
	# @param key [String] the key
	# @return [any] the value
	#
	_getCurrentValueFor: ( key ) ->
		return @_changes[ key ]  if @_changes[ key ]?
		return _( @module[ key ] ).clone( true )

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
					@_changes[ key ] = @_getCurrentValueFor( key )
					if event.target.checked
						@_changes[ key ].push value if @_changes[ key ].indexOf( value ) is -1
					else
						@_changes[ key ] = _( @_changes[ key ] ).without value
				else
					@_changes[ key ] = value
				
				@_triggerChange( key, value )
			)
		) key
	
	# Triggers the cahnge
	#
	# @param key [String] the key changed
	# @param value [any] the new value
	#
	_triggerChange: ( key, value ) ->
		console.debug "trigger change #{key} to #{value}"
		@_trigger( 'module.properties.change', @_parent, [ @_changes, key, value, @_currents ] )
		
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
			value: () => value ? ( if multiple then [] else '' )
			
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
		
		for option in _( _(options.concat values.value()).filter( ( v ) -> v? and v.length > 0) ).uniq()
			
			label = $( "<label class='option-selectable #{selectable.type}' for='#{selectable.id}-#{option}'></label>" )
			elem = $( "<input type='#{selectable.type}' name='#{selectable.name}' id='#{selectable.id}-#{option}' value='#{option}'>" )
			elem.attr( 'checked', values.contains(option) ) #default value
			elem.prop( 'checked', values.contains(option) ) #current value
			@_bindOnSelectableChange( selectable.key, elem )

			text = option?.split( '#' )[0]
			color = Helper.Mixable.hashColor text	
			
			display_name = option.replace( /#(.*)/, '' )
			labeltext = $("<span class='badge #{selectable.drawtype} #{if !options.contains(option) then 'unknown' else ''}'>#{display_name}</span>")
			labeltext.css('background', color)
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
		if selected
			@_getThisForm().find( '[data-selectable]').find('input').parent().removeClass('selectable-hide')
		else
			@_getThisForm().find( '[data-selectable]').find('input:not(:checked)').parent().addClass('selectable-hide')			
		
	# Gets this form element
	#
	# @return [jQuery.Elem]
	#
	_getThisForm: () ->
		return $( "##{@getFormId()}" )
		
	# Resets this form element
	#
	_resetThisForm: () ->
		@_getThisForm()[0].reset()
		@_getThisForm().find( '.control-group' ).removeClass( 'error' )
		return this
		
	# Sets the selection state of this popover
	# 
	# @param selected [Boolean] the selection state
	#
	setSelected: ( selected ) ->
		super selected
		
		@_getThisForm()
			.find( 'input, select' )
			.not( '.disabled')
			.prop( 'disabled', !selected )
			
		@_setSelectablesVisibility( selected )

		if selected	
			@_elem.focus()
			@_elem.find('input[type=text]:enabled').first().select()

			@_elem.keyup( ( e ) => 
				switch e.keyCode
					when 27
						@_close()
					when 13
						@_save()
			)
		else
			@_elem.find( 'input' ).blur()
			@_elem.off( 'keyup' )
			@_resetThisForm()

	# Returns the properties of our module
	#
	_getModuleProperties: () ->
		return @module.metadata.properties

	# Closes the module
	#
	_close: ( ) =>
		@_changes = {}
		@_trigger( 'view.module.selected', @_parent, [ undefined, off ] )

	# Resets this view
	#
	_reset: () =>
		@_body?.empty()
		@_selectables = []
		@_drawForm()

	# Saves all changed properties to the module.
	#
	_save: ( ) =>	
		return if not @_saveChanges()
		@_changes = {}
		@_trigger( 'view.module.selected', @_parent, [ undefined, off ] )
		
	# Remove button clicked
	#
	_remove: () =>
		@_trigger( 'view.module.removed', @_parent, [] )
		
	# Saves the changes
	#
	@catchable
		_saveChanges: () ->
			result = true
			missing_keys = []
			wrong_keys = []
			for key, value of @_changes
				input = $( '#' + @getInputId( key ) )
				input.closest( '.control-group' ).removeClass( 'error')
				if not value?
					result = false
					missing_keys.push key
					input.closest( '.control-group' ).addClass( 'error' )
				else if isNaN( value ) and input.attr( 'type') is 'number'
					result = false
					wrong_keys.push key
					input.closest( '.control-group' ).addClass( 'error' )
				
			if not result
				message = ''
				message += "I need #{missing_keys}. " if missing_keys.length
				message += "I need valid values for #{wrong_keys}." if wrong_keys.length
				throw new Error message
			
			@_trigger( 'view.module.saved', @_parent, [ @_changes ] )
			return true
			
	# Catcher function for Mixin.Catcher that will notificate any thrown Error on catchable methods
	#
	# @param e [Error] the error to notificate
	#
	_catcher: ( source, e ) =>
		text = if _( e ).isObject() then e.message ? 'no message' else e 
		@_notificate( @, @module, text , text, [], View.RaphaelBase.Notification.Error)
			
	# Runs when a compound is changed (added/removed)
	#
	# @param cell [Model.Cell] changed on
	# @param module [Model.Module] the changed compound
	#
	_onCompoundsChanged: ( cell, module ) ->
		return if cell isnt @_cell
		@_compounds = @_cell.getCompoundNames()
		@_redrawSelectable( selectable ) for selectable in @_selectables
	
	# Runs when a metabolite is changed (added/removed)
	#
	# @param cell [Model.Cell] changed on
	# @param module [Model.Metabolite] the changed metabolite
	#
	_onMetabolitesChanged: ( cell, module ) ->
		return if cell isnt @_cell
		@_metabolites = @_cell.getMetaboliteNames()
		@_redrawSelectable( selectable ) for selectable in @_selectables
			
	# Gets called when a module view is drawn.
	#
	# @param module [Module] the module that is being drawn
	#
	_onModuleDrawn: ( module ) ->
		@setPosition() if module is @module

	# Gets called when a module's parameters have changed
	#
	# @param module [Module] the module that has changed
	#
	_onModuleInvalidated: ( module, action ) ->
		@_reset() if module is @module
