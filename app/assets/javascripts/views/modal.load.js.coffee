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
				thead = $ '<thead><th>#</th><th>Name</th><th>Creation</th><th class="span2"></th></thead>' 
				tbody = $ '<tbody></tbody>'
				
				for cell in cells.reverse()
					row = $ '<tr></tr>'
					row.append $ "<td>#{cell.id}</td>"
					row.append $ "<td>#{cell.name}</td>"
					row.append ( time = $ "<td></td>" )
					time.append @_parseDate cell.created_at
					
					load_button = $ '<button class="btn btn-primary" data-dismiss="modal" data-action="load" aria-hidden="true" data-id="' + cell.id + '"><i class="icon-download icon-white"></i> Load</button>'
					load_button.on( 'click', ( event ) => 
						@cell = $( event.currentTarget ).data( 'id' ) 
					)
					
					row.append( action = $ "<td></td>" )
					action.append load_button
					
					tbody.append row
				
				table.append thead
				table.append tbody
				body.append table
			)
			.fail( () -> body.text( 'Error.' ) )
		return this
		
	# Parse date
	#
	# @param date [String] string date in format
	# @return [Date]
	# 
	_parseDate: ( date ) ->
		matchOffset = /(Z|([+-])(\d\d):(\d\d))$/
		offset = matchOffset.exec date
		result = new Date( date.replace( 'T', ' ' ).replace( matchOffset, '' ) )
		timezone = 0
		unless offset[ 1 ] is 'Z' 
			timezone = ( if offset[ 2 ] is '+' then -1 else 1 ) * ( offset[ 3 ] * 60 + Number( offset[ 3 ] ) )
		result.setMinutes( result.getMinutes() + timezone - result.getTimezoneOffset() )
		
		time = $ "<time datetime='#{date}' title='#{result}'></time>"
		time.append ( @_prettifyDate result )
		return time
		
	#
	#
	_prettifyDate: ( date ) ->
		diff = ( Date.now() - date.getTime() ) / 1000
		console.log diff
		steps = [ 
			[ 60, 'seconds' ]
			[ 60, 'minutes' ]
			[ 24, 'hours' ]
			[ 4, 'days' ] # up to 3 days ago
		]
		
		for step in steps
			step[ 1 ]  = step[ 1 ].substring( 0, step[ 1 ].length - 1 ) if 1 <= diff < 2
			return "#{ Math.floor( diff ) } #{ step[ 1] } ago" if diff < step[0]
			diff /= step[ 0 ]
		return "#{date.getFullYear()} - #{date.getMonth()} - #{date.getDay()}"
		