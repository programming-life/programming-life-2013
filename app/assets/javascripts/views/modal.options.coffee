# Provides an HTML Modal
#
class View.OptionsModal extends View.HTMLModal

	# Constructs a new Modal view.
	#
	# @param id [String] the id
	# @param classname [String] additiona classname(s)
	#
	constructor: ( id, classname ) ->
		header = 'Options'
		super header, '', id, classname
		
	# Create the modal body
	#
	# @return [jQuery.Elem] the body element
	#
	_createBody: () ->
		body = super()
		form = $ '<form class="form"></from>'
		
		form.append $ '<div class="control-group"><div class="controls">lalala</div></div>'
		
		
		body.append form

	#  Create the modal footer
	#
	_createFooter: () ->
		footer = $ '<div class="modal-footer"></div>'
		close = $ '<button class="btn" data-action="close" data-dismiss="modal" aria-hidden="true">Close</button>'
		footer.append close
		return [ footer, close ]