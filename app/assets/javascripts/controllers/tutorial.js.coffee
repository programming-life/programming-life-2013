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
		CreateFromDummy: 5
		CreateSave: 6
		CreatedAutomagic: 7
		ModuleDelete: 8
		
		# Automagic/Previews
		CreatePrecursors: 8
		
	#
	#
	@Group:
		Start: 		[ 'Start' ]
		Finished: 	[ 'Finished' ]
		
		Inspecting:	[ 'OverviewHover', 'OverviewSelect', 'OverviewClose', 'OverviewEnd' ]
		Adding: 	[ 'CreateFromDummy', 'CreateSave', 'CreatedAutomagic', 'ModuleDelete' ]
		Automagic:	[ 'CreatePrecursors' ]
		
	#
	#
	@Order: [
		'Start'
		'Inspecting'
		'Adding'
		'Automagic'
		'Finished'
		]
	
	#
	#
	@Title:
		Inspecting: 'Inspecting modules'
		Adding: 'Adding modules'
		Automagic: 'Precursors and Previews'

	# Creates a new instance of Tutorial
	#
	# @param parent [Controller.Main] the main controller
	# @param view [View.Tutorial] the view for this controller
	#
	constructor: ( @parent, view ) ->	
	
		@InverseStep = _( Tutorial.Step ).invert() 
	
		parent =
			getAbsolutePoint: ( location ) ->
				return [ $( window ).width() - 20, 20 ]
			
		@_canceled = locache.get( 'tutorial.cancelled' ) ? off
		@_step = locache.get( 'tutorial.at' ) ? Tutorial.Step.Start
		@_incurEventNextOnTestDebounce = _( @_incurEventNextOnTest ).debounce 300
	
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
		title = @_getTitle @_step
		[ now, max ] = @_getProgress @_step
		message = @_getMessage @_step
		nextOnEvent = @_bindFor @_step
		title = "#{title} #{now}/#{max}" if max > 1
		@view.showMessage( title, message, nextOnEvent, animate, amount )

	# Gets the title for a step
	#
	# @param step [Integer] the step
	# @return [String] the title
	# 
	_getTitle: ( step ) ->
		name = @InverseStep[ step ]
		return Tutorial.Title[ @_getGroupKey name ] ? 'Tutorial'
			
	# Gets the pgoress for this step
	#
	_getProgress: ( step ) ->
		name = @InverseStep[ step ]
		group = Tutorial.Group[ @_getGroupKey name ]
		result = null
		if _( group ).find( ( _name, index ) -> 
			result = index
			return name is _name  )
			return [ result + 1, group.length ]
		return [ '?', group.length ]
		
	#
	#
	#
	_getMessage: ( step ) ->
		switch step
			when Tutorial.Step.Start
				return [ 
					'<p>This is <strong>Gigabase</strong>. Your <i>virtual</i> cell.</p>'
					'<p>It seems like this is your first time here. Let me guide you through the process of creating your first cell.</p>'
					'<p>At any time you can cancel the tutorial by pressing the <span class="badge badge-inverse"><i class="icon-remove icon-white"></i> stop</span> button or the <span class="badge badge-inverse"><i class="icon-remove icon-white"></i></span> mark in the top right corner. To resume, simply press the <span class="badge badge-inverse"> <i class="icon-question-sign icon-white"></i></span>.</p>'
					'<p>You can also minimize the tutorial by pressing <span class="badge badge-inverse"><i class="icon-minus icon-white"></i></span>. Complete your task or press the <span class="badge badge-inverse"><i class="icon-question-sign icon-white"></i></span> to resume.</p>'
					'<p>Let' + "'" + 's start! Press the <span class="badge badge-inverse">Next <i class="icon-chevron-right icon-white"></i></span> button.</p>'
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
					'<p>Opening the properties popover of this module has hidden something on the palette. There is a button below the popover that I can not quite see.</p>'
					'<p class="alert alert-info"><b>Close the Cell Growth popover</b>, by clicking the <span class="badge badge-inverse"><i class="icon-remove icon-white"></i></span> button or clicking the module again.</p>'
				]
				
			when Tutorial.Step.OverviewEnd
				return [
					'<p>Good job! That is it for inspecting modules.</p>'
					'<p class="alert alert-success">You can close modules by clicking the <span class="badge badge-inverse"><i class="icon-remove icon-white"></i></span> button, clicking the module, or any other module, or pressing <span class="badge badge-inverse"><abbr title="escape">ESC</abbr></span> on your keyboard.</p>'
					'<p>No one likes solitude. So let me teach you about <b>Adding modules</b>. Press the <span class="badge badge-inverse">Next <i class="icon-chevron-right icon-white"></i></span> button.</p>'
				]
				
			when Tutorial.Step.CreateFromDummy
				lipidText = $("<span class='badge compounds'>lipid</span>")
				lipidText.css('background', Helper.Mixable.hashColor 'lipid' )
				
				return [
					'<p>For the cell to live, we will need some <i>infrastructure</i>. We have seen the infrastructure properties of the <i>Cell Growth</i> module. One of those items was ' + $( '<div></div>' ).append( lipidText ).html() + '. I still think some company is in order.</p>'
					'<p>Look! We have a template on our palette. Time to find that loner a friend.</p>'
					'<p class="alert alert-info"><b>Click <span class="badge badge-inverse">Add Lipid</span></b> to start adding the lipid.</p>'
				]
				
			when Tutorial.Step.CreateSave
				return [
					'<p class="alert alert-success">Clicking a <b>template module</b>, indicated by the transparent background and the dashed border, starts te creation process.</p>'
					'<p>Marvelous! You started the create-a-module process, or as I like to call it friend-for-cellgrowth process. We could change all these values, but lets not. I will show you how to deal with that later.</p>'
					'<p class="alert alert-info"><b>Save the module</b>, by clicking the <span class="badge badge-inverse"><i class=" icon-ok icon-white"></i> Create</span> button.</p>'
				]
				
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
	_incurEventNext: () ->
		@view.hide( ( () => @_nextStep( @_getNextStep( @_step ) ) ), 'left', 10 )
		
	#
	#
	_incurEventNextOnTest: () ->
		return unless @_latestTest
		@_incurEventNext()
	
	#
	#
	_CellGrowthHoverTest: ( view, event, state ) =>
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@_latestTest = state
			@_incurEventNextOnTestDebounce()
	
	#
	#
	#
	_CellGrowthSelectTest: ( view, event, state ) =>
		return unless state
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@_incurEventNext()
			
	#
	#
	#
	_LipidSelectTest: ( view, event, state ) =>
		return unless state
		if view instanceof View.DummyModule and view.model instanceof Model.Lipid
			@_incurEventNext()
	
	#
	#
	#
	_CellGrowthCloseTest: ( view, event, state ) =>
		return if state
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@_incurEventNext()
			
	# Gets the next step
	#
	# @param step [Integer] the current step
	# @return [Integer] the next step
	#
	_getNextStep: ( step ) ->
		name = @InverseStep[ step ]
		group_key = @_getGroupKey name
		group = Tutorial.Group[ group_key ]
		result = null
		if _( group ).find( ( _name, index ) -> 
			result = index
			return name is _name  )
			if group.length > result + 1
				return Tutorial.Step[ group[ result + 1] ]
			return Tutorial.Step[ _( @_getNextGroup( group_key ) ).first() ]
			
		return step
		
	# Gets the next group
	#
	# @param group_key [String] the current group key
	# @return [Array<String>] the next group 
	#
	_getNextGroup: ( group_key ) ->
		result = null
		if _( Tutorial.Order ).find( ( _group, index ) -> 
			result = index
			return group_key is _group  )
			if Tutorial.Order.length > result + 1
				return Tutorial.Group[ Tutorial.Order[ result + 1 ] ]
			return Tutorial.Group[ _( Tutorial.Order ).first() ]
		return Tutorial.Group[ group_key ]
		
	# Gets the previous step
	#
	# @param step [Integer] the current step
	# @return [Integer] the previous step
	#
	_getBackStep: ( step ) ->
		name = @InverseStep[ step ]
		group_key = @_getGroupKey name
		group = Tutorial.Group[ group_key ]
		result = null
		if _( group ).find( ( _name, index ) -> 
			result = index
			return name is _name  )
			if result > 0
				return Tutorial.Step[ group[ result - 1 ] ]
			return Tutorial.Step[ _( @_getBackGroup( group_key ) ).last() ]
			
		return step
		
	# Gets the previous group
	#
	# @param group_key [String] the current group key
	# @return [Array<String>] the previous group 
	#
	_getBackGroup: ( group_key ) ->
		result = null
		if _( Tutorial.Order ).find( ( _group, index ) -> 
			result = index
			return group_key is _group  )
			if result > 0
				return Tutorial.Group[ Tutorial.Order[ result - 1 ] ]
			return Tutorial.Group[ _( Tutorial.Order ).last() ]
		return Tutorial.Group[ group_key ]

	# Gets the group key for a step name
	#
	# @param name [String] the step name/key
	# @return [String] the group name/key
	#
	_getGroupKey: ( name ) ->
		result = null
		if _( Tutorial.Group ).find( ( group, key ) -> 
			result = key
			return name in group  )
			return result
		return null
		
	# Binds events for the step
	#
	# @param step [Integer] the step id
	# @return [Boolean] true if something was bound
	#
	_bindFor: ( step ) =>
		switch step
			when Tutorial.Step.OverviewHover
				@parent.view.hidePanes()
				@_bind( 'view.module.hovered', @, @_CellGrowthHoverTest )
				return on
			when Tutorial.Step.OverviewSelect
				@_bind( 'view.module.selected', @, @_CellGrowthSelectTest )
				return on
			when Tutorial.Step.OverviewClose
				@_bind( 'view.module.selected', @, @_CellGrowthCloseTest )
				return on
			when Tutorial.Step.CreateFromDummy
				@_bind( 'view.module.selected', @, @_LipidSelectTest )
				return on
			else 
				return off
		
	# Unbinds events for the step
	#
	# @param step [Integer] the step id
	# @return [Boolean] true if something was unbound
	#
	_unbindFor: ( step ) =>
		switch step
			when Tutorial.Step.OverviewHover
				@_unbind( 'view.module.hovered', @, @_CellGrowthHoverTest )
				return on
			when Tutorial.Step.OverviewSelect
				@_unbind( 'view.module.selected', @, @_CellGrowthSelectTest )
				return on
			when Tutorial.Step.OverviewClose
				@_unbind( 'view.module.selected', @, @_CellGrowthCloseTest )
				return on
			when Tutorial.Step.CreateFromDummy
				@_unbind( 'view.module.selected', @, @_LipidSelectTest )
				return on
			else 
				return off
		
	# Shows the view
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
