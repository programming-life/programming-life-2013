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
		
		$( '#actions' ).on( 'click', '[data-action]', @onAction )
		
	# Loads a new cell into the main view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback ) ->
		promise = @view.load cell_id, callback
		promise.done( () => @_setCellNameActionField( @view.cell.model.name ) )
		return promise
		
	# Saves the main view cell
	#
	# @return [jQuery.Promise] the promise
	#
	save: () ->
		name = @_getCellNameActionField()
		return @view.save( name )
		
	# Gets the cell name from the action field
	#
	# @return [String] the cell name
	#
	_getCellNameActionField: () ->
		value = $( '#cell_name' ).val()
		return null if value.length is 0
		return value ? null
		
	# Sets the cell name to the action field
	# 
	# @param name [String] the name
	# @return [self] chainable self
	#
	_setCellNameActionField: ( name ) ->
		value = $( '#cell_name' ).val name
		return this
		
	#
	#
	_getProgressBar: () ->
		return $( '#progress' )
	
	#
	#
	_setProgressBar: ( value ) =>
		@_getProgressBar().find( '.bar' ).css( 'width', "#{value * 100 / @_num + 100 / @_num * @_curr }%" )
		if ( value is 1 )
			if ++@_curr is @_num
				@_getProgressBar().css( 'opacity', 0 )
			
		return this
	
	# Finds the action buttons
	#
	# @return [jQuery.Collection] the action buttons
	#
	_findActionButtons: () ->
		return $( '#actions' ).find( '[data-action]' )
		
	# Runs on an action (click)
	#
	# @param event [jQuery.Event] the event
	#
	onAction: ( event ) =>
		
		@_findActionButtons()
			.removeClass( 'btn-success' )
			.removeClass( 'btn-danger' )
			.prop( { disabled :  true } )
			.filter( ':not([data-toggle])' )
				.filter( ':not([class*="btn-warning"])' )
				.find( 'i' )
					.removeClass( 'icon-white' )

		enable = () => 
			@_findActionButtons()
				.prop( 'disabled', false )
			
		success = () => target.button( 'success' ).addClass( 'btn-success' ) 
		error = () => target.button( 'error' ).addClass( 'btn-danger' ) 
		
		target = $( event.target )
		
		switch target.data( 'action' )

			when 'save'
				target.button('loading')
				@save().always( enable )
					.done( success )
					.fail( error )
					
			when 'load'
				target.button('loading')
				
				confirm = ( id ) =>
					console.log id, id?
					if id?
						@load( id )
							.always( enable )
							.done( success )
							.fail( error )
					else
						enable()
						error()
				
				cancel = () =>
					target.button( 'reset' )
					enable()
				
				@view.showLoad( confirm, cancel )
					
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
				@_findActionButtons()
					.button( 'reset' )
				
				confirm = () =>
					@view.kill()
					@view = new View.Main @container
					
				@view.confirmReset( confirm )
				
			when 'simulate'
				target.attr( 'disabled', false )
				action = not target.hasClass( 'active' )
				
				# hack
				@_num = 2
				@_curr = 0
				
				ppromise = @view.toggleSimulation action
				if action
					@_getProgressBar().css( 'visibility', 'visible' )
					@_getProgressBar().css( 'opacity', 1 )
					ppromise.progress @_setProgressBar
					ppromise.always enable
					ppromise.always () -> target.button( 'toggle' ) if target.hasClass( 'active' )
				else
					@_getProgressBar().css( 'opacity', 0 )
					enable()
			else
				enable()
				
	kill: () ->
		$( '#actions' ).find( '[data-action]' ).removeProp( 'disabled' )
	