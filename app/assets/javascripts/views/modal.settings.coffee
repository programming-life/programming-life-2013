# Provides an HTML Modal
#
class View.SettingsModal extends View.HTMLModal

	# Constructs a new Modal view.
	#
	# @param id [String] the id
	# @param classname [String] additiona classname(s)
	#
	constructor: ( @_settings, id, classname ) ->
		header = 'Settings'
		super header, '', id, classname
		
	# Create the modal body
	#
	# @return [jQuery.Elem] the body element
	#
	_createBody: () ->
		body = super()
		form = $ '<form id="settings-modal" class="form-horizontal"></from>'
		
		for section, options of @_settings
			form.append @_createControlSection section, options
				
		body.append form
		
	# Create section
	# 
	# @param section [String] the section name
	# @param options [Object] the options
	# @return [jQuery.Elem] the element
	#
	_createControlSection: ( section, options ) ->
		control_section = $ '<fieldset></fieldset>'
		control_section.append( legend = $ '<legend>' + section + '</legend>' )	
		
		for option, meta_data of options
			control_section.append @_createControlGroup( section, option, option, meta_data )
		
	# Create control group for an options
	#
	# @param section [String] the parent section
	# @param label [String] the label to show
	# @param key [String] the option key
	# @param meta_data [Object] the meta data
	# @options meta_data [String] type the type of the data
	# @options meta_data [any] value the value of the data
	# @options meta_data [Integer] min the minumum value
	# @options meta_data [Integer] max the maximum value
	# @options meta_data [Integer] step the step value
	# @options meta_data [String] active the active discriptor
	#
	_createControlGroup: ( section, label, key, meta_data ) ->
	
		type = switch meta_data.type
			when 'number'
				'number'
			when 'boolean'
				'checkbox'
			else
				'text'
	
		id = 'option-' + section + '-' + key
		group = $ '<div class="control-group"></div>'
		group.append( label = $ '<label class="control-label" for="' + id + '">' + label + '</label>' )
		group.append( controls = $ '<div class="controls"></div>' )
		input = $ '<input data-section="' + section + '" data-key="' + key + '" class="input-medium" type="' + type + '" id="' + id + '" value="' + meta_data.value + '"/>'
		
		switch type
			when 'number'
				input.attr( 'min', meta_data.min )
					.attr( 'max', meta_data.max )
					.attr( 'step', meta_data.step )
			when 'checkbox'
				input.attr( 'value', true )
				input.attr( 'checked', meta_data.value )
				wrapper = $ '<label class="checkbox"></label>'
				input = wrapper.append input
				wrapper.append meta_data.active
		
		controls.append input
		return group
		
	# Gets all the input fields
	#
	# @return [jQuery.Collection] the input fields
	#
	getInput: () ->
		return $( '#settings-modal' ).find( '[data-key]' )

	#  Create the modal footer
	#
	_createFooter: () ->
		footer = $ '<div class="modal-footer"></div>'
		close = $ '<button class="btn" data-action="close" data-dismiss="modal" aria-hidden="true">Close</button>'
		footer.append close
		return [ footer, close ]