# Displays the properties of a dummy module in a neat HTML popover
#
class View.DummyModuleProperties extends View.ModuleProperties

	# Constructs a new DummyModuleProperties view.
	#
	# @param parent [View.Module] the accompanying module view
	# @param cellView [View.Cell] the accompanying cell view
	# @param cell [Model.Cell] the parent cell of the module
	# @param modulector [Function] the constructor for the dummy module
	# @param params [Object] options
	#
	constructor: ( parent, @_cellView, @_cell, @modulector, @_override_params = {} ) ->
		@_dummyId = _.uniqueId('dummy-module-')

		@_compounds = @_cell.getCompoundNames()
		@_metabolites = @_cell.getMetaboliteNames()
		@_params = _( @_override_params ).clone( true )
		@_changes = _( _( @_params ).clone( true ) ).defaults( @_getModuleDefaults() )
		@_selectables = []

		# Behold, the mighty super constructor train! Reminds me of some super plumber called Mario.
		@constructor.__super__.constructor.__super__.constructor.apply( @, [parent, @modulector.name, 'module-properties', 'bottom'] )

		@_bind( 'module.selected.changed', @, @_onModuleSelected )

		@_bind( 'module.creation.started', @, @_onModuleCreationStarted )
		@_bind( 'module.creation.finished', @, @_onModuleCreationFinished )
		@_bind( 'module.creation.aborted', @, @_onModuleCreationAborted )

		@_bind( 'cell.module.added', @, @_onCompoundsChanged )
		@_bind( 'cell.module.removed', @, @_onCompoundsChanged )
		@_bind( 'cell.metabolite.added', @, @_onMetabolitesChanged )
		@_bind( 'cell.metabolite.removed', @, @_onMetabolitesChanged )

	# Gets the id for this popover
	#
	getFormId: ( ) ->
		return 'properties-form-' + @_dummyId

	# Gets the id for an input with a certain key
	#
	# @param key [String] the key for which to get the id
	#
	getInputId: ( key ) ->
		return 'property-' + @_dummyId + '-' + key

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

	#  Create footer content and append to footer
	#
	# @param onclick [Function] the function to yield on click
	# @param saveText [String] the text on the save button
	# @return [Array<jQuery.Elem>] the footer and the button element
	#
	_createFooter: ( removeText = '<i class="icon-trash icon-white"></i>', saveText = '<i class=" icon-ok icon-white"></i> Create' ) ->
		@_footer = $('<div class="modal-footer"></div>')

		@_saveButton = $('<button class="btn btn-primary" data-action="create">' + saveText + '</button>')
		@_saveButton.click @_save
		
		@_footer.append @_saveButton
		return [ @_footer, @_saveButton ]

	# Draws the input for a parameter
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	_drawName: ( id, key, value ) ->
		elem = super(id, key, value)
		elem.prop('disabled', false).removeClass('disabled')
		return elem

	# Draws a certain property
	#
	# @param key [String] property
	# @param type [String] property type
	# @param params [Object] additional parameters
	# @return [jQuery.elem] elements
	#
	_drawProperty: ( key, type, params = {} ) ->
		return @_drawInput( type, key, @_changes[ key ] ? undefined, params )
		
	# Draws the input for an enumeration
	#
	# @param id [String] the form id
	# @param key [String] property to set
	# @param value [any] the current value
	#
	# @todo on clear/kill remove property from option
	#
	_drawEnumeration: ( id, key, value, params ) ->
		select = super( id, key, value, params )
		if key is 'placement' or key is 'direction'
			select.prop( 'disabled', false )
			select.removeClass( 'disabled' )
		return select

	# Returns the properties of our module to be
	#
	# @return [Object] the properties
	#
	_getModuleProperties: ( ) ->
		properties = @modulector.getParameterMetaData().properties

		unless properties.parameters?
			properties.parameters = []

		properties.parameters.push('amount')
		return properties
		
	# Returns the defaults of our module to be
	# 
	# @return [Object] the defaults
	#
	_getModuleDefaults: ( ) ->
		defaults = @modulector.getParameterDefaults()
		defaults.amount = defaults.starts.name
		return defaults
		
	# Closes the module
	#
	_close: ( ) =>
		@_trigger( 'module.creation.aborted', @_parent )
		@_elem.find('input').blur()
		
	# Saves all changed properties to the module.
	#
	_save: ( ) =>
		return if not @_validateCreation()
	
		@_trigger('module.creation.finished', @_parent, [ @_changes ])
		@_elem.find('input').blur()
		@_reset()
		
	# Validates creation
	#
	#
	@catchable	
		_validateCreation: () ->
			form = $( '#' + @getFormId() )
			
			result = true
			message = 'I need valid input values'
			for input in form.find( 'input[type="number"]' )
				input = $( input )
				input.closest( '.control-group' ).removeClass( 'error')
				if not input.val() or isNaN( input.val() )
					input.closest( '.control-group' ).addClass( 'error')
					result = false
			throw Error( message ) if not result
			return true
			
	# Catcher function for Mixin.Catcher that will notificate any thrown Error on catchable methods
	#
	# @param e [Error] the error to notificate
	#
	_catcher: ( source, e ) =>
		text = if _( e ).isObject() then e.message ? 'no message' else e 
		@_notificate( @, @_parent, text , text, [], View.RaphaelBase.Notification.Error)
		
	# Resets the popover module
	# 
	_reset: () =>
		@_changes = _( _( @_params ).clone( true ) ).defaults( @_getModuleDefaults() )
		super()

	# Gets the current value for a key
	# 
	# @param key [String] the key to get
	# @return [any] the current value
	#
	_getCurrentValueFor: ( key ) ->
		return if @_changes[ key ] then @_changes[ key ] else []
		
	# Triggers when changed  a key
	# 
	# @param key [String] the key of the change
	# @param value [any] the new value
	#
	_triggerChange: ( key, value ) ->
		console.debug "trigger change #{key} to #{value}"
		@_trigger( 'dummy.properties.change', @_parent, [ @_changes, key, value, @modulector ] )
		
	# Will be called when the creation process of a module has started
	# 
	# @param dummy [DummyModule] the dummy module for which to start the creation
	#
	_onModuleCreationStarted: ( dummy ) ->
		if dummy is @_parent
			@setPosition()
			@_setSelected on
		else if @_selected
			@_setSelected off 

	# Will be called when the creation process of a module has aborted
	#
	# @param dummy [DummyModule] the dummy module for which to abort the creation
	#
	_onModuleCreationAborted: ( dummy ) ->
		if dummy is @_parent and @_selected
			@_setSelected off

	# Will be called when the creation process of a module has finished
	#
	# @param dummy [DummyModule] the dummy module for which to finish the creation
	#
	_onModuleCreationFinished: ( dummy ) ->
		if dummy is @_parent and @_selected
			@_setSelected off


