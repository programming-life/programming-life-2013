# Provides an HTML Modal
#
# @concern Mixin.EventBindings
#
class View.HTMLModal extends Helper.Mixable

	@concern Mixin.EventBindings
	
	# Constructs a new Modal view.
	#
	# @param _header [String] the header text
	# @param _contents [String] the contents text
	# @param id [String] the id
	# @param classname [String] additiona classname(s)
	#
	constructor: ( @_header, @_contents, id, classname ) ->
		@_id = id ? _.uniqueId 'modal-'
		@_elem = @_create classname

		Object.defineProperty( @, 'id',
			get: -> @_id
		)
		
		@_allowEventBindings()
		@draw()
		
	# Shows the modal
	#
	show: () ->
		@_action = undefined
		@_elem.modal 'show'
		return this
	
	# Hides the modal
	#
	hide: () ->
		@_elem.modal 'hide'
		return this
	
	# Toggles the modal
	#
	toggle: () ->
		@elem.modal 'toggle'
		return this
		
	# Binds function on close (before transition)
	#
	onClose: ( context, action ) ->
		@_bind( 'modal.confirm.close', context, action )
		return this
		
	# Unbinds function on close (before transition)
	#
	offClose: ( context, action ) ->
		@_unbind( 'modal.confirm.close', context, action )
		return this
		
	# Binds function on closed (after transition)
	#
	onClosed: ( context, action ) ->
		@_bind( 'modal.confirm.closed', context, action )
		return this
		
	# Unbinds function on closed (after transition) 
	#
	offClosed: ( context, action ) ->
		@_unbind( 'modal.confirm.closed', context, action )
		return this
		
	# Creates the modal element
	#
	# @param classname [String] the additional classname
	# @return [jQuery.Elem] the modal element
	#
	_create: ( classname = '' ) ->	
		elem = $('<div id="' + @_id + '" class="modal hide fade ' + classname + '" 
			tabindex="-1" role="dialog" aria-hidden="true"></div>' )
		$('body').append elem
		return elem
		
	# Kills the modal
	#
	kill: () ->
		@_elem?.remove()
		@_unbindAll()
		return this
		
	# Removes the properties' modal from the body
	#
	clear: ( ) ->
		@_elem?.empty()
		return this
		
	# Draws the modal
	#
	draw: ( ) ->
		@clear()
		
		[ header ] = @_createHeader()
		[ footer ] = @_createFooter()	
		
		@_elem.append header if header?
		@_elem.append @_createBody()
		@_elem.append footer if footer?	
		
		@_elem.find( '[data-dismiss="modal"]' )
			.on( 'click', ( event ) =>
				@_action = $( event.target ).data( 'action' )
			)
			
		@_elem.on( 'hide', () => @_trigger( 'modal.confirm.close', @, [ @_action ] ) )
		@_elem.on( 'hidden', () => @_trigger( 'modal.confirm.closed', @, [ @_action ] ) )
		
	# Create the modal header
	#
	_createHeader: ( ) ->	
		header = $ '<div class="modal-header"></div>'
		button = $ '<button type="button" class="close" data-action="close" data-dismiss="modal" aria-hidden="true">×</button>'
		header.append $( "<h3>#{@_header}</h3>" )
		return [ header, button ]
		
	# Create the modal body
	#
	# @return [jQuery.Elem] the body element
	#
	_createBody: () ->
		@_body = $ '<div class="modal-body"></div>'
		@_body.html @_contents
		return @_body
		
	#  Create the modal footer
	#
	_createFooter: () ->
		footer = $ '<div class="modal-footer"></div>'
		button = $ '<button class="btn" data-dismiss="modal" data-action="close" aria-hidden="true">Close</button>'
		footer.append button
		return [ footer, button ]
	