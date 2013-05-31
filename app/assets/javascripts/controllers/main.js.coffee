# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# The controller for the Main action and view
#
class Controller.Main extends Controller.Base

	# Creates a new instance of Main
	#
	# @param container [String, Object] A string with an id or a DOM node to serve as a container for the view
	#
	constructor: ( @container, view ) ->
		super view ? ( new View.Main @container )
		@view.bindActionButtonClick( () => @onAction( arguments... ) ) 
	
		@addChild new Controller.Cell( @view, @view.cell.model, @view.cell )
		@addChild new Controller.Undo( @view.cell.model.timemachine, @view.undo )
		
	# Loads a new cell into the main view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback ) ->
		promise = @view.load cell_id, callback
		promise.always( () => @_setCellNameActionField( @view.cell.model.name ) )
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
		return @view.getCellName()
		
	# Sets the cell name to the action field
	# 
	# @param name [String] the name
	# @return [self] chainable self
	#
	_setCellNameActionField: ( name ) ->
		@view.setCellName name
		return this
		
	# Gets the progress bar
	#
	_getProgressBar: () ->
		return @view.getProgressBar()
	
	# Sets the progress bar
	#
	# @param value [Integer] the current value
	#
	_setProgressBar: ( value ) =>
		@view.setProgressBar value / @_num + 1 / @_num * @_curr
		if ( value is 1 )
			if ++@_curr is @_num
				@view.hideProgressBar()
			
		return this
		
	# Runs on an action (click)
	#
	# @param event [jQuery.Event] the event
	#
	onAction: ( event ) =>
		
		@view.resetActionButtons()
		enable = () => @view.enableActionButtons()
			
		success = () => @view.setButtonState( target, 'success', 'btn-success' ) 
		error = () => @view.setButtonState( target, 'error', 'btn-danger' ) 
		
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
		@view.setButtonState target, 'loading'
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
		@view.setButtonState target, 'loading'
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
		@view.setButtonState target, 'loading'
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
	# @todo action should be more dynamic for child controllers and views
	#
	onReset: ( target, enable, success, error ) ->
		@view.resetActionButtonState()
		
		action = () =>
			@view.kill()
			Model.EventManager.clear()
			@view = new View.Main @container
			
		@view.confirmReset action
		
	# On Simulate Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	onSimulate: ( target, enable, success, error ) ->
		target.attr( 'disabled', false )
		startSimulateFlag = not target.hasClass( 'active' )
		
		# hack
		@_num = 2
		@_curr = 0
		
		[ ppromise, token ] = @view.setSimulationState startSimulateFlag
		if startSimulateFlag is on
			@_token = token
			@view.showProgressBar()
			ppromise.progress @_setProgressBar
			ppromise.always enable
			ppromise.always () => @view.setButtonState(target, 'toggle') if target.hasClass( 'active' )
		else
			@_token?.cancel()
			@view.hideProgressBar()
			enable()