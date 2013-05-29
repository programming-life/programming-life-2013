# View for extensible Pane
#
class View.Pane extends Helper.Mixable
	
	@Position:
		Left: 'left'
		Right: 'right'

	# Creates a new Pane
	#
	# @param position [View.Pane.Position] The side the pane needs to be on
	#
	constructor: ( @position ) ->
		@_extended = off
		@_buttonWidth = 40

		@_containerOptions = {}

		@_views = []
	
	# Clears this view
	#
	clear: ( ) ->
		for view in @_views
			view.kill()
	
	# Kills the view
	#
	kill: ( ) ->		
		@_elem?.remove()
		
	# Draw the view
	#
	# @param position [View.Pane.Position] The side the pane needs to be on
	#
	draw: ( position = @position ) ->
		@kill()

		@_elem = $('<div class="pane"></div>')
		@_elem.addClass("pane-#{position}")

		button = $('<div class="pane-button"></div>')
		button.click( =>
			@toggle()
		)
		@_elem.append(button)

		for view in @_views
			@_elem.append(view.draw())

		$('body').append(@_elem)

	# Add a view to draw in the container
	#
	# @param view [Object] The view to add
	#
	addView: ( view ) ->
		@_views.push(view)
		@draw()

	# Removes a view from the container
	#
	# @param [Object] The view to remove
	#
	removeView: ( view ) ->
		@_views = _( @_views ).without view
		@draw()

	# Toggle the panes extension
	#
	toggle: ( ) ->
		if @_extended
			@retract()
		else
			@extend()		
	
	# Extends the pane if not already extended
	#
	extend: ( ) ->
		@_elem.addClass('extended')
		@_extended = on
	
	# Retracts the pane if not already retracted
	#
	retract: ( ) ->
		@_elem.removeClass('extended')
		@_extended = off