'use strict'
# The controller for the Main action and view
#
class Controller.Main extends Controller.Base
	
	@concern Mixin.TimeMachine
	
	#
	#
	@NOTIFICATION_TIMEOUT: 1000 * 15

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
	
		# Unobtrusive notifications view
		parent =
			getAbsolutePoint: ( location ) ->
				return [ $( window ).width() / 2, 20 ]
				
		@view.add ( @_globalNotifications = new View.Notification( parent, 'global', 'global' ) )
	
		# Child Controllers
		@addChild 'settings', new Controller.Settings()
		@addChild 'cell', new Controller.Cell( @view.paper, @view, @cellFromCache( 'main.cell' ) )
		@addChild 'graphs', new Controller.Graphs( "#graphs" )
		@addChild 'undo', new Controller.Undo( @timemachine )
		@addChild 'tutorial', new Controller.Tutorial( this )
		@addChild 'presentation', new Controller.Presentation( this )

		# Child Views
		@view.add @controller('cell').view
		@view.add @controller('graphs').view
		@view.addToLeftPane @controller('undo').view

		
		# Update view
		@_setCellNameActionField( if @controller( 'cell' ).model.isLocal() then '' else  @controller( 'cell' ).model.name )

		@_onCellViewSet( @controller("cell").view, @controller("cell").model, true )
	
	# Creates the timemachine for the main controller
	#
	#
	_createTimeMachine: ( ) ->
		@timemachines = []
		@timemachine.setRoot new Model.Node(@controller("cell").model.tree.root.object)
		@timemachine.current = @timemachine.root

		modules = @controller("cell").model.getModules()
		modules.unshift @controller("cell").model
		for module in modules
			timemachine = @addTimeMachine @controller("cell").model, module
			for node in timemachine.iterator()
				@_onNodeAdd timemachine, node
	
	# Gets called on view set
	#
	# @param view [View.Cell] The view that was set
	# @param model [Model.Cell] The new cell model of the view
	# @param created [Boolean] True if the cell was created, false if it was loaded
	#
	_onCellViewSet: ( view, model, created = false ) ->
		if view is @controller("cell").view	
			@controller('undo').setTimeMachine( @timemachine ) 
			@controller('graphs').clear()
			if created
				action = model._createAction "Created cell"
			else
				action = model._createAction "Loaded cell"
			model.timemachine.setRoot new Model.Node( action )
			@_createTimeMachine()
		
	# Creates bindings
	#
	_createBindings: () ->
		@view.bindActionButtonClick( () => @onAction( arguments... ) ) 
		@_bind( 'view.cell.set', @, @_onCellViewSet )
		@_bind( 'module.selected.changed', @, 
			(module, selected) => 
				@controller('undo').focusTimeMachine if selected
					module.timemachine 
				else 
					@timemachine 
		)
		@_bind( 'cell.metabolite.added', @, @addTimeMachine )
		@_bind( 'cell.module.added', @, @addTimeMachine )
		@_bind( 'tree.node.added', @, @_onNodeAdd )
		@_onNotificate( @, 'global', _( () -> @_globalNotifications?.hide() ).debounce( Main.NOTIFICATION_TIMEOUT ) )

		@controller("undo").view.bindKeys([90,false,true,false], @controller("undo"), @controller("undo").undo ) # Bind ctrl + z to undo
		@controller("undo").view.bindKeys([89,false,true,false], @controller("undo"), @controller("undo").redo ) # Bind ctrl + y to redo
		@view.bindKeys([82,false,true,false], @, () -> $('[data-action="reset"]').click() ) # Bind ctrl + r to reset
	
	# Gets called when a node is added to a tree
	#
	# @param tree [Model.Tree] The tree that the node was added to
	# @param node [Model.Node] The node
	#
	_onNodeAdd: ( tree, node ) ->
		if tree in @timemachines and node isnt tree.root
			@addUndoableEvent(node.object)

		
	# Load cell from cache
	#
	# @param key [String] the key of the cell
	# @return [Model.Cell,null] the result from cache
	#
	cellFromCache: ( key ) ->
		cached = locache.get( 'main.cell' )
		return if cached? then Model.Cell.deserialize( cached ) else null
		
	# Loads a new cell into the main view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback, clone = off ) ->
		promise =  @controller('cell').load cell_id, callback, clone
		promise.always( () => @_setCellNameActionField( @controller('cell').model.name ) )
		return promise
		
	# Saves the main view cell
	#
	# @return [jQuery.Promise] the promise
	#
	save: ( clone = off ) ->
		name = @_getCellNameActionField()
		return @controller('cell').save( name, clone )
		
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
		
		btn_target = target = $( event.currentTarget )
		btn_target = target.closest( '.btn-group' ).find( 'button[data-action]' ) if target.is( 'a' )

		@view.resetActionButtons()
		enable = () => @view.enableActionButtons()
		success = () => @view.setButtonState( btn_target, 'success', 'btn-success' ) 
		error = () => @view.setButtonState( btn_target, 'error', 'btn-danger' ) 

		action = target.data( 'action' )
		action = action.charAt(0).toUpperCase() + action.slice(1)
		
		if @[ '_on' + action ]?
			@[ '_on' + action ]( btn_target, enable, success, error )
		else
			enable()
				
	# On Save Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	_onSave: ( target, enable, success, error ) ->
		@view.setButtonState target, 'loading'
		@view.setNotificationsOn( @controller('cell').model, 'button[data-action="save"]' )
		@save().always( enable )
			.done( success )
			.fail( error )
			.fail( @_onSaveError )
		
	# On Save error occurred
	#
	_onSaveError: ( data ) =>
		[ error, cell ] = data
		switch error.status
			when 404
				button = $ '<button id="solution" class="btn btn-small" data-action="saveAs">Save As</button>'
				button.on( 'click', => $( '#actions [data-action="saveAs"]' ).click() )
				message = 'It seems like the cell you are trying to save was deleted. You can try to "save as" a new cell.'
				@view.setSolutionNotification( message, button )
			when 0
				button = $ '<button id="solution" class="btn btn-small" data-action="load">Open Load</button>'
				button.on( 'click', => $( '#actions [data-action="load"]' ).click() )
				message = "The server could not be reached. Your cell is local stored and you can find it under load. When" +
				" a connection is established, I will try to save your cell. You don't need to do anything."
				@view.setSolutionNotification( message, button )
		
	# On Save As Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	_onSaveAs: ( target, enable, success, error ) ->
		@view.setButtonState target, 'loading'
		@view.setNotificationsOn( @controller('cell').model, 'button[data-action="save"]' )
		@save( true ).always( enable )
			.done( success )
			.fail( error )
			
	# On Load Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	_onLoad: ( target, enable, success, error ) ->
		@view.setButtonState target, 'loading'
		confirm = ( id ) =>
			callback = ( res ) => @view.setNotificationsOn( res, 'button[data-action="load"]' )
			if id?
				@load( id, callback )
					.always( enable )
					.done( success )
					.fail( error )
			else
				enable()
				error()
				
		other = ( action, id ) =>
			if id? and action is 'clone'
				@load( id, undefined, true )
					.always( enable )
					.done( success )
					.fail( error )
			target.button( 'reset' )
			enable()
		
		cancel = () =>
			target.button( 'reset' )
			enable()
		
		@view.showLoad( confirm, other, cancel )

		
	# On Report Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	#
	_onReport: ( target, enable, success, error ) ->
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
			
	# On Tutorial Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	# @todo action should be more dynamic for child controllers and views
	#
	_onHelp: ( target, enable, success, error ) ->
		@view.resetActionButtonState()
		@controller( 'tutorial' ).show( )
			
	# On Options Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	# @todo action should be more dynamic for child controllers and views
	#
	_onOptions: ( target, enable, success, error ) ->
		@view.resetActionButtonState()
		@controller( 'settings' ).show( )
	
	# On Reset Button clicked
	#
	# @param target [jQuery.Elem] target element
	# @param enable [Function] function to re-enable buttons
	# @param succes [Function] function to run on success
	# @param error [Function] function to run on error
	# @todo action should be more dynamic for child controllers and views
	#
	_onReset: ( target, enable, success, error ) ->
		@view.resetActionButtonState()
		
		action = () =>
			@kill()
			@flush()
			Model.EventManager.clear()

			@view = new View.Main @container
			@_createChildren()
			@_createBindings()
			@_createTimeMachine()
			
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
	_onSimulate: ( target, enable, success, error ) ->
		target.attr( 'disabled', false )
		startSimulateFlag = not target.hasClass( 'active' )
		
		iterationDone = ( results, from, to ) =>
			@controller( 'graphs' ).show( results.datasets, @_currentIteration > 0 )
			@_currentIteration++
			@_setProgressBar 0
			
		@_iterations = @controller( 'settings' ).options.simulate.iterations
		@_currentIteration = 0
		[ token, progress_promise ] = @controller('cell').setSimulationState startSimulateFlag, iterationDone, @controller( 'settings' ).options
		if startSimulateFlag is on
			@_token = token
			@view.hidePanes()
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
	# @returns [Mixin.TimeMachine] The timemachine
	#
	addTimeMachine: ( cell, tm ) ->
		if cell is @controller("cell").model
			@timemachines.push tm.timemachine
		return tm.timemachine
	
	# Time to store any unstored files
	#
	onUpdate: () ->
		promise = $.Deferred()
		locache.async.get( 'cells').finished( ( cells ) ->
			
			if not cells?
				promise.resolve()
				return
			
			tryResolve = () ->
				if --counter is 0
					promise.resolve()
			
			counter = cells.length
			for key in cells
				(( cell_key ) ->
					locache.async.get( cell_key ).finished( ( cell ) ->
						
						if not cell?
							tryResolve()
							return
							
						cell = Model.Cell.deserialize( cell )
						if Helper.Mixable.extractId( cell.id ).origin isnt 'server'
							cell.save().always( () ->
								tryResolve()
							)
						else
							tryResolve()
					)
				)( key )
		)
		return promise.promise()
	
	# On Upgrade resy
	# @todo show notification, not modal on revision
	#
	onUpgrade: () ->
		
		$.get( '/version' ).done( ( version ) => 
		
			if ( version.major > GIGABASE_VERSION.major )
				contents = $ ( '<div></div>' )
				contents.append 'A <strong>new version</strong> of the application is ready and has been downloaded to your computer. You are' +
								' <strong>required</strong> to <a href="#" class="btn btn-mini" data-action="refresh" onclick="document.locat' +
								'ion.reload(true);">refresh</a> this page to upgrade to version ' + version.full + '. Changes made before th' +
								'is dialog popped up are stored and will be available after you refreshed.<br>You are currently running ' + 
								GIGABASE_VERSION.full  + '.'
				
				view = new View.HTMLModal( 
					'Major upgrade!', 
					contents, 
					'upgrade-notice', 'upgrade-notice upgrade-major' 
				)
				@view.add view
				view.onClosed( view, view.show )
				
			if ( version.major > GIGABASE_VERSION.major or version.minor > GIGABASE_VERSION.minor )
			
				contents = $ ( '<div></div>' )
				contents.append 'A <strong>new version</strong> of the application is ready and has been downloaded to your computer. Simply ' +
								'<a href="#" class="btn btn-mini" data-action="refresh" onclick="document.location.reload(true);">refresh</a>' +
								' this page to upgrade to version ' + version.full + '. Changes made before this dialog popped up are stored ' +
								'and will be available after you refreshed.<br>You are currently running ' + GIGABASE_VERSION.full + '.'
				
				view = new View.HTMLModal( 
					'Minor upgrade!', 
					contents, 
					'upgrade-notice', 'upgrade-notice upgrade-minor' 
				)
				@view.add view
				view.show()
			else if ( version.revision > GIGABASE_VERSION.revision )
				@_notificate( this, 'global', 'upgrade', 
					'Update available. <a href="#" class="btn btn-mini" data-action="refresh" onclick="document.location.reload(true);">Refres' +
					'h</a> this page to upgrade to version ' + version.full + '.' 
				)
		)
				
	# Flushes the cache
	#
	flush: () ->
		locache.remove( 'main.cell' )
	
	# On unload, stores the cell
	#
	onUnload: () =>
		locache.set( 'main.cell', @controller("cell").model.serialize() )
		super()
