'use strict'
# The controller for the Main action and view
#
class Controller.Tutorial extends Controller.Base

	#
	#
	@Step:	
		Finished: -1
		
		Start: 0
		Overview: 1

	# Creates a new instance of Tutorial
	#
	# @param parent [Controller.Main] the main controller
	# @param view [View.Tutorial] the view for this controller
	#
	constructor: ( @parent, view ) ->
	
		parent =
			getAbsolutePoint: ( location ) ->
				return [ $( window ).width() - 20, 20 ]
			
		@_canceled = locache.get( 'tutorial.cancelled' ) ? off
		@_step = locache.get( 'tutorial.at' ) ? Tutorial.Step.Start
	
		super view ? ( new View.Tutorial parent )
		
		@_createBindings()
		
		unless ( @_canceled or @_step is Tutorial.Step.Finished )
			@_nextStep @_step, 'top', -10
			
	# Create default bindings for the view
	#
	_createBindings: () ->
		@_bind( 'view.tutorial.next', @, () => @_nextStep( @_getNextStep( @_step ), 'left', 10 ) )
		@_bind( 'view.tutorial.back', @, () => @_nextStep( @_getBackStep( @_step ), 'left', -10 ) )
		@_bind( 'view.tutorial.cancel', @, () => 
			@_unbindAll()
			@_createBindings() 
			@_canceled = on
		)
	
	#
	#
	#
	_nextStep: ( step, animate = 'left', amount = 10 ) ->
		@_unbindFor @_step
		@_step = step
		locache.async.set( 'tutorial.at', @_step )
		message = @_getMessage @_step
		nextOnEvent = @_bindFor @_step
		@view.showMessage( message, nextOnEvent, animate, amount )

	#
	#
	#
	_getMessage: ( step ) ->
		switch step
			when Tutorial.Step.Start
				return [ 
					'<p>This is <strong>Gigabase</strong>. Your <i>virtual</i> cell.</p>', 
					'<p>It seems like this is your first time here. Let me guide you through the process of creating your first cell.</p>'
					'<p>At any time you can cancel the tutorial by pressing the close button or the &times; mark in the top right corner. To resume, simply press the <i class="icon-question-sign"></i>.</p>',
					'<p>You can also minimize the tutorial by pressing <i class="icon-minus"></i>. Complete your task or press the <i class="icon-question-sign"></i> to resume.</p>',
					'<p>Let' + "'" + 's start! Press the <i class="icon-chevron-right"></i> button.</p>'
				]
			
			when Tutorial.Step.Overview
				return [
					'<p>I retracted that pane on the left for you. We don' + "'" + 't like distractions.</p>'
					'<p>Before you, you can see the cell. I suppose that purple module feels very lonely.</p>'
					'<p>Click it, to see what we are dealing with.</p>'
				]
				
			when Tutorial.Step.Finished
				return [ 'You have completed the tutorial!', 'Now start building your own cell.' ]
	
	#
	#
	_overviewTest: ( view, event, state ) ->
		console.log view, view.model, view.selected
		return unless state
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@_nextStep( @_getNextStep( @_step ) )
			
	#
	#
	_getNextStep: ( step ) ->
		switch step
			when Tutorial.Step.Start
				return Tutorial.Step.Overview
				
			when Tutorial.Step.Overview
				return Tutorial.Step.Finished
				
			when Tutorial.Step.Finished
				return Tutorial.Step.Start
				
		return step
		
	#
	#
	_getBackStep: ( step ) ->
		switch step
			when Tutorial.Step.Start
				return Tutorial.Step.Finished
				
			when Tutorial.Step.Overview
				return Tutorial.Step.Start	
				
			when Tutorial.Step.Finished
				return Tutorial.Step.Overview
		return step
	
	#
	#
	_bindFor: ( step ) ->
		switch step
			when Tutorial.Step.Overview
				@_bind( 'view.module.selected', @, @_overviewTest )
				on
			else 
				off
		
	#
	#
	_unbindFor: ( step ) ->
		switch step
			when Tutorial.Step.Overview
				@_unbind( 'view.module.selected', @ )
				on
			else
				off
		
	#
	#
	show: ( ) ->
		return unless @_canceled or not @view.visible
		@_canceled = off
		@_step = Tutorial.Step.Start if @_step is Tutorial.Step.Finished
		@_nextStep @_step, 'top', -10
		
	# On unload, stores the cell
	#
	onUnload: () =>
		locache.set( 'tutorial.at', @_step )
		locache.set( 'tutorial.cancelled', @_canceled )
		super()
