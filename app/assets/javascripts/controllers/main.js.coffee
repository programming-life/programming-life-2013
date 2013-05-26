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
		
	
	# Finds the action buttons
	#
	_findActionButtons: () ->
		return $( '#actions' ).find( '[data-action]' )
		
	#
	#
	action: ( event ) =>
		
		@_findActionButtons()
			.removeClass( 'btn-success' )
			.removeClass( 'btn-danger' )
			.prop( { disabled :  true } )
			.filter( ':not([data-toggle])' )
				.removeClass( 'btn-primary' )
				.filter( ':not([class*="btn-warning"])' )
				.find( 'i' )
					.removeClass( 'icon-white' )

		enable = () => 
			@_findActionButtons()
				.prop( 'disabled', false )
				.filter( ':not([data-toggle])' )
					.removeClass( 'btn-primary' )
			
		success = () => target.button( 'success' ).addClass( 'btn-success' ) 
		error = () => target.button( 'error' ).addClass( 'btn-danger' ) 
		
		target = $( event.target ).addClass( 'btn-primary' )
		
		switch target.data( 'action' )

			when 'save'
				target.button('loading')
				@save().always( enable )
					.done( success )
					.fail( error )
					
			when 'load'
				target.button('loading')
				@load( 1 ).always( enable )
					.done( success )
					.fail( error )
					
			when 'report'
				target.button('loading')
				@save().then( () => 
						console.log( 'actually create report for ' + @view.cell.model.id ) 
						# first call the code to generate it ( e.g. create or update )
						# then when the response comes in, redirect the browser ( ex: window.location / .href )
					)
					.done( success )
					.fail( error )
					.always( enable )
				
			when 'reset'
				@view.kill()
				@view = new View.Main @container
				enable()
				
			when 'simulate'
				target.attr( 'disabled', false )
				@view.toggleSimulation not target.hasClass( 'active' )
				enable() if target.hasClass( 'active' )
			else
				enable()
				
	kill: () ->
		$( '#actions' ).find( '[data-action]' ).removeProp( 'disabled' )
	