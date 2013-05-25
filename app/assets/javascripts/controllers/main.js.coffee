# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# The controller for the Main action and view
#
class Controller.Main

	# Creates a new instance of Main
	#
	# @param container [String, Object] A string with an id or a DOM node to serve as a container for the view
	#
	constructor: ( @container ) ->
		@view = new View.Main @container
		
		$( '#actions' ).on( 'click', '[data-action]', @action )
		
	# Loads a new cell into the main view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback ) ->
		return @view.load cell_id, callback
		
	# Saves the main view cell
	#
	# @return [jQuery.Promise] the promise
	#
	save: () ->
		return @view.save()
		
	
	#
	#
	_findActionButtons: () ->
		return $( '#actions' ).find( '[data-action]' )
		
	#
	#
	action: ( event ) =>
		
		@_findActionButtons()
			.prop( 'disabled', true )
			.removeClass( 'btn-success' )
			.removeClass( 'btn-danger' )
			.removeClass( 'btn-primary' )
			.button( 'reset' )
		
		enable = () => @_findActionButtons().prop( 'disabled', false ).removeClass( 'btn-primary' )
		success = () => target.button( 'success' ).addClass( 'btn-success' ) 
		error = () => target.button( 'error' ).addClass( 'btn-danger' ) 
		
		target = $( event.target ).addClass( 'btn-primary' )
		
		switch target.data( 'action' )
			when 'save'
				target.button('loading')
				@save().always( enable ).done( success ).fail( error )
			when 'load'
				target.button('loading')
				@load( 1 ).always( enable ).done( success ).fail( error )
			when 'reset'
				@view.kill()
				@view = new View.Main @container
				enable()
			else
				enable()
				
	kill: () ->
		$( '#actions' ).find( '[data-action]' ).removeProp( 'disabled' )
	