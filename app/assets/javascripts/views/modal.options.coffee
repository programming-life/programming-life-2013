# Provides an HTML Modal
#
class View.OptionsModal extends View.HTMLModal

	#  Create the modal footer
	#
	_createFooter: () ->
		footer = $ '<div class="modal-footer"></div>'
		close = $ '<button class="btn" data-action="close" data-dismiss="modal" aria-hidden="true">Close</button>'
		footer.append close
		return [ footer, close ]
		
	
	