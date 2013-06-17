'use strict'
# The controller for the Main action and view
#
class Controller.Tutorial extends Controller.Base

	#
	#
	@Step:	
		Finished: -1
		
		Start: 0
		
		# Inspecting modules
		OverviewHover: 1
		OverviewSelect: 2
		OverviewClose: 3
		OverviewEnd: 4
		
		# Adding Module
		CreateDummy: 5
		CreatedAutomagic: 6
		ModuleDelete: 7
		
		# Automagic/Previews
		CreatePrecursors: 8

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
					'<p>This is <strong>Gigabase</strong>. Your <i>virtual</i> cell.</p>'
					'<p>It seems like this is your first time here. Let me guide you through the process of creating your first cell.</p>'
					'<p>At any time you can cancel the tutorial by pressing the close button or the &times; mark in the top right corner. To resume, simply press the <i class="icon-question-sign"></i>.</p>'
					'<p>You can also minimize the tutorial by pressing <i class="icon-minus"></i>. Complete your task or press the <i class="icon-question-sign"></i> to resume.</p>'
					'<p>Let' + "'" + 's start! Press the <span class="badge badge-inverse"><i class="icon-chevron-right icon-white"></i></span> button.</p>'
				]
			
			when Tutorial.Step.OverviewHover
				return [
					'<p>I retracted that pane on the left for you. We don' + "'" + 't like distractions. Take a look at your palette right now, but <b>do not click</b> anything.</p>'
					'<p>In the center of your screen you can see your cell. I suppose that purple module feels very lonely.</p>'
					'<p class="alert alert-info"><b>Hover it</b>, to see what we are dealing with here.</p>'
				]
				
			when Tutorial.Step.OverviewSelect
				return [
					'<p>Ah, it seems to be the <i>Cell Growth</i> module. It keeps track of the <i>population size</i>. The Cell Growth module is always required in the cell, because without it we can not simulate a polulation. </p>'
					'<p>There is a lot of information here. We can see the <i>name</i> of the module, the <i>initial amount</i>, the metabolites used to calculate the <b>mu</b> and the required <i>infrastructure</i>. All modules have different properties and you can simply hover them to see those properties.</p>'
					'<p class="alert alert-info"><b>Click on the module</b>, to edit the module.</p>'
				]
				
				#I did so by pressing the <span class="badge badge-inverse"><i class="icon-chevron-left icon-white"></i> button</span> on the left side.
				
			when Tutorial.Step.OverviewClose
				return [
					'<p>This is how we can edit the properties of a module. All the information has turned editable, except for the name.</p>'
					'<p class="alert alert-warning">Once a module is named, <b>its name is fixed</b>. Recreate the module if you want to change the name.</p>'
					'<p>I still think this module needs some company. There is a button below the popover that I can not quite see.</p>'
					'<p class="alert alert-info"><b>Close the Cell Growth popover</b>, by clicking the <span class="badge badge-inverse">&times;</span> button or clicing the module again.</p>'
				]
				
			when Tutorial.Step.OverviewEnd
				return [
					'<p>Good job! That is it for inspecting modules.</p>'
					'<p class="alert alert-success">You can close modules by clicking the <span class="badge badge-inverse">&times;</span> button, clicking the module, or any other module, or pressing <span class="badge badge-inverse"><abbr title="escape">ESC</abbr></span> on your keyboard.</p>'
					'<p>No one likes solitude. So let me teach you about <b>Adding modules</b>. Press the <span class="badge badge-inverse"><i class="icon-chevron-right icon-white"></i></span> button.</p>'
				]
				
			when Tutorial.Step.CreateDummy
				return []
				
			when Tutorial.Step.CreatedAutomagic
				return []
			
			when Tutorial.Step.ModuleDelete
				return []
				
			when Tutorial.Step.CreatePrecursors
				return []
				
			when Tutorial.Step.Finished
				return [ 'You have completed the tutorial!', 'Now start building your own cell.' ]
	
	#
	#
	_OverviewHoverTest: ( view, event, state ) =>
		console.log 'hover', arguments
		return unless state
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@view.hide( ( () => @_nextStep( @_getNextStep( @_step ) ) ), 'left', 10 )
			
	#
	#
	#
	_OverviewSelectTest: ( view, event, state ) =>
		console.log 'selected', arguments
		return unless state
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@view.hide( ( () => @_nextStep( @_getNextStep( @_step ) ) ), 'left', 10 )
	
	#
	#
	#
	_OverviewCloseTest: ( view, event, state ) =>
		console.log 'close', arguments
		return if state
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@view.hide( ( () => @_nextStep( @_getNextStep( @_step ) ) ), 'left', 10 )
			
	#
	#
	_getNextStep: ( step ) ->
		switch step
			when Tutorial.Step.Start
				return Tutorial.Step.OverviewHover
				
			# Inspecting modules
			when Tutorial.Step.OverviewHover
				return Tutorial.Step.OverviewSelect
			when Tutorial.Step.OverviewSelect
				return Tutorial.Step.OverviewClose
			when Tutorial.Step.OverviewClose
				return Tutorial.Step.OverviewEnd
			when Tutorial.Step.OverviewEnd
				return Tutorial.Step.CreateDummy
				
			# Adding module
			when Tutorial.Step.CreateDummy
				return Tutorial.Step.CreatedAutomagic
			when Tutorial.Step.CreatedAutomagic
				return Tutorial.Step.ModuleDelete
			when Tutorial.Step.ModuleDelete
				return Tutorial.Step.CreatePrecursors
				
			# Previews / Automagic
			when Tutorial.Step.CreatePrecursors
				return Tutorial.Step.Finished
			
			# Changing module
			
			# Simulate 
			
			# Save
			
			# Load
			
			# Settings
				
			when Tutorial.Step.Finished
				return Tutorial.Step.Start
				
		return step
		
	#
	#
	_getBackStep: ( step ) ->
		switch step
			when Tutorial.Step.Start
				return Tutorial.Step.Finished
				
			# Inspeciting module
			when Tutorial.Step.OverviewHover
				return Tutorial.Step.Start	
			when Tutorial.Step.OverviewSelect
				return Tutorial.Step.OverviewHover
			when Tutorial.Step.OverviewClose
				return Tutorial.Step.OverviewSelect
			when Tutorial.Step.OverviewEnd	
				return Tutorial.Step.OverviewClose
				
			# Adding module
			when Tutorial.Step.CreateDummy
				return Tutorial.Step.OverviewEnd
			when Tutorial.Step.CreatedAutomagic
				return Tutorial.Step.CreateDummy
			when Tutorial.Step.ModuleDelete
				return Tutorial.Step.CreatedAutomagic
				
			# Previews / Automagic
			when Tutorial.Step.CreatePrecursors
				return Tutorial.Step.ModuleDelete
			when Tutorial.Step.Finished
				return Tutorial.Step.CreatePrecursors
		return step
	
	#
	#
	_bindFor: ( step ) =>
		switch step
			when Tutorial.Step.OverviewHover
				@parent.view.hidePanes()
				@_bind( 'view.module.hovered', @, @_OverviewHoverTest )
				return on
			when Tutorial.Step.OverviewSelect
				@_bind( 'view.module.selected', @, @_OverviewSelectTest )
				return on
			when Tutorial.Step.OverviewClose
				@_bind( 'view.module.selected', @, @_OverviewCloseTest )
				return on
			else 
				return off
		
	#
	#
	_unbindFor: ( step ) =>
		switch step
			when Tutorial.Step.OverviewHover
				@_unbind( 'view.module.hovered', @, @_OverviewHoverTest )
				return on
			when Tutorial.Step.OverviewSelect
				@_unbind( 'view.module.selected', @, @_OverviewSelectTest )
				return on
			when Tutorial.Step.OverviewClose
				@_unbind( 'view.module.selected', @, @_OverviewCloseTest )
				return on
			else 
				return off
		
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
