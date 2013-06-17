'use strict'
# The controller for the Main action and view
#
class Controller.Tutorial extends Controller.Base

	#
	#
	@Step:	
		Finished: 1
		Start: 0

	# Creates a new instance of Tutorial
	#
	# @param parent [View.Main] the main view
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
			@_nextStep @_step
			
	#
	#
	_createBindings: () ->
		@_bind( 'view.tutorial.next', @, () => @_nextStep( @_getNextStep( @_step ) ) )
		@_bind( 'view.tutorial.back', @, () => @_nextStep( @_getBackStep( @_step ) ) )
		@_bind( 'view.tutorial.cancel', @, () => 
			@_unbindAll()
			@_createBindings() 
			@_canceled = on
		)
	
	#
	#
	#
	_nextStep: ( step ) ->
		message = @_getMessage step
		nextOnEvent = @_bindFor step
		@view.showMessage( message, nextOnEvent )

	#
	#
	#
	_getMessage: ( step ) ->
		switch step
			when Tutorial.Step.Start
				return 'This is Gigabase. Your virtual cell.'
			
	#
	#
	_getNextStep: ( step ) ->
		return step
		
	#
	#
	_getBackStep: ( step ) ->
		return step
	
	#
	#
	_bindFor: ( step ) ->
		off
		
	#
	#
	show: ( ) ->
		return unless @_canceled or not @view.visible
		@_canceled = off
		@_step = Tutorial.Step.Start if @_step is Tutorial.Step.Finished
		@_nextStep @_step
		
	# On unload, stores the cell
	#
	onUnload: () =>
		locache.set( 'tutorial.at', @_step )
		locache.set( 'tutorial.cancelled', @_canceled )
		super()
