# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# The controller for the Main action and view
#
class Controller.Main extends Controller.Base
	
	@concern Mixin.TimeMachine

	# Creates a new instance of Main
	#
	# @param container [String, Object] A string with an id or a DOM node to serve as a container for the view
	# @param view [View.Main] the view for this controller
	#
	constructor: ( @container, view ) ->
		super view ? ( new View.Main @container )

		@_allowTimeMachine()
		@timemachines = []
	
		@_createChildren()
		@_createBindings()

		
	# Creates children
	#
	_createChildren: () ->
		@addChild 'cell', new Controller.Cell( @view.paper, @view )
		@timemachines.push @controller("cell").model.timemachine
		@timemachine.setRoot new Model.Node(@controller("cell").model.tree.root.object)
		@addChild 'graphs', new Controller.Graphs( @view.paper )
		@addChild 'undo', new Controller.Undo( @timemachine )
		
		@view.add @controller('cell').view
		@view.add @controller('graphs').view
		@view.addToLeftPane @controller('undo').view
		
	# Creates bindings
	#
	_createBindings: () ->
		
		@view.bindActionButtonClick( () => @onAction( arguments... ) ) 
	
		@_bind( 'view.cell.set', @, 
			( cell ) => @controller('undo').setTimeMachine( @timemachine ) 
		)
		
		@_bind( 'module.selected.changed', @, 
			(module, selected) => 
				@controller('undo').setTimeMachine if selected
					module.timemachine 
				else 
					@timemachine 
		)
		@_bind( 'cell.metabolite.added', @, @addTimeMachine )
		@_bind( 'cell.module.added', @, @addTimeMachine )
		@_bind( 'tree.node.added', @, 
			( tree, node ) => 
				if tree in @timemachines
					@addUndoableEvent(node.object)
		)
		
	# Loads a new cell into the main view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback ) ->
		promise =  @controller('cell').load cell_id, callback
		promise.always( () => @_setCellNameActionField( @controller('cell').model.name ) )
		return promise
		
	# Saves the main view cell
	#
	# @return [jQuery.Promise] the promise
	#
	save: () ->
		name = @_getCellNameActionField()
		return @controller('cell').save( name )
		
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
		@view.setProgressBar value / @_iterations + 1 / @_iterations * @_currentIteration
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
			@kill()
			Model.EventManager.clear()
			@view = new View.Main @container
			@_createChildren()
			@_createBindings()
			
		@view.confirmReset action
		
	# On Simulate Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	# @todo hack remove
	#
	onSimulate: ( target, enable, success, error ) ->
		target.attr( 'disabled', false )
		startSimulateFlag = not target.hasClass( 'active' )
		
		iterationDone = ( results, from, to ) =>
			@controller( 'graphs' ).show( results.datasets, @_currentIteration > 0 )
			@_currentIteration++
			@_setProgressBar 0
			
		@_iterations = 4
		@_currentIteration = 0
		[ token, progress_promise ] = @controller('cell').setSimulationState startSimulateFlag, iterationDone, 20, @_iterations
		if startSimulateFlag is on
			@_token = token
			@view.showProgressBar()
			progress_promise.progress @_setProgressBar
			progress_promise.always enable
			progress_promise.always () => @view.setButtonState( target, 'toggle' ) if target.hasClass( 'active' )
			progress_promise.done () => @view.hideProgressBar()
		else
			@_token?.cancel()
			@view.hideProgressBar()
			enable()
	
	# Adds a timemachine to the list of timemachines this timemachine can control
	#
	# @param cell [Model.Cell] The source of the event
	# @param tm [Mixin.TimeMachine] The object containing the timemachine
	#
	addTimeMachine: ( cell, tm ) ->
		if cell is @controller("cell").model
			@timemachines.push tm.timemachine
