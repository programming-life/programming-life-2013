# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# The controller for the Main action and view
#
class Controller.Main extends Helper.Mixable

	@concern Mixin.EventBindings

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
		
	# Gets the progress bar
	#
	_getProgressBar: () ->
		return $( '#progress' )
	
	# Sets the progress bar
	#
	# @param value [Integer] the current value
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
		
		target = $( event.currentTarget )
		action = target.data( 'action' )
		action = action.charAt(0).toUpperCase() + action.slice(1)
		
		if @[ 'on' + action ]?
			@[ 'on' + action ]( target, enable, success, error )
		else
			enable()
				
	# On Save Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	onSave: ( target, enable, success, error ) ->
		target.button('loading')
		@save().always( enable )
			.done( success )
			.fail( error )
			
	# On Load Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	onLoad: ( target, enable, success, error ) ->
		target.button('loading')
				
		confirm = ( id ) =>
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
		
	# On Report Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	onReport: ( target, enable, success, error ) ->
	
		target.button('loading')
		@save().then( ( cell ) =>
				cell = cell[0] if _( cell ).isArray()
				return $.post( '/reports.json', { report: { cell_id: cell.cell_id } } )
					.then( 
						(data) ->
							window.location.href = "/reports/#{ data.id }"
					)	
			)
			.done( success )
			.fail( error )
			.always( enable )
	
	# On Reset Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	onReset: ( target, enable, success, error ) ->
		@_findActionButtons()
			.button( 'reset' )
		
		confirm = () =>
			@view.kill()
			Model.EventManager.clear()
			@view = new View.Main @container
			
		@view.confirmReset( confirm )
		
	# On Simulate Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	onSimulate: ( target, enable, success, error ) ->
		target.attr( 'disabled', false )
		action = not target.hasClass( 'active' )
		
		# hack
		@_num = 2
		@_curr = 0
		
		[ ppromise, token ] = @view.toggleSimulation action
		if action
			@_token = token
			@_getProgressBar().css( 'visibility', 'visible' )
			@_getProgressBar().css( 'opacity', 1 )
			ppromise.progress @_setProgressBar
			ppromise.always enable
			ppromise.always () -> target.button( 'toggle' ) if target.hasClass( 'active' )
		else
			@_token?.cancel()
			@_getProgressBar().css( 'opacity', 0 )
			enable()
				
	# Kills this controller
	#
	kill: () ->
		$( '#actions' ).find( '[data-action]' ).removeProp( 'disabled' )
