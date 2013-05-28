# Provides an HTML Modal
#
# @concern Mixin.EventBindings
#
class View.LoadModal extends View.HTMLModal

	# Constructs a new Modal view.
	#
	# @param _header [String] the header text
	# @param _contents [String] the contents text
	# @param id [String] the id
	# @param classname [String] additiona classname(s)
	#
	constructor: ( id, classname ) ->
		header = "Select a cell to load"
		contents = '<div class="contents"></div>'
		@cell = null
		
		super header, contents, id, classname
		
	#  Create the modal footer
	#
	_createFooter: () ->
		footer = $ '<div class="modal-footer"></div>'
		cancel_button = $ '<button class="btn" data-dismiss="modal" data-action="cancel" aria-hidden="true"><i class="icon-remove"></i> Cancel</button>'
		footer.append cancel_button
		return [ footer, cancel_button ]
		
	# Shows the modal
	#
	show: () ->
		@_action = undefined
		@_elem.modal 'show'
		
		body = $( "##{ @_id }" ).find( '.modal-body .contents' )
		body.text( 'Loading...' ) 
		
		Model.Cell.loadList()
			.done( ( cells ) =>  
				body.empty()
						
				table = $ '<table class="table table-condensed"></table>'
				table.append( thead = $ '<thead><th>#</th><th>Name</th><th class="span2"></th></thead>' ) #<th>Created on</th>
				
				table.append( tbody = $ '<tbody><tbody>' )
				for cell in cells.reverse()
					row = $ '<tr></tr>'
					row.append $ "<td>#{cell.id}</td>"
					row.append $ "<td>#{cell.name}</td>"
					#row.append $ "<td>#{cell.created_at}</td>"
					
					load_button = $ '<button class="btn btn-primary" data-dismiss="modal" data-action="load" aria-hidden="true" data-id="' + cell.id + '"><i class="icon-download icon-white"></i> Load</button>'
					load_button.on( 'click', ( event ) => 
						@_action = $( event.target ).data( 'action' )
						@cell = $( event.target ).data( 'id' ) 
					)
					
					row.append( action = $ "<td></td>" )
					action.append load_button
					
					tbody.append row
				
				table.append tbody
				
				body.append table
			)
			.fail( () -> body.text( 'Error.' ) )
		return this