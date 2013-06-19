# Adds presentation functionality to it's parent
#
class Controller.Presentation extends Controller.Base
	
	
	# Constructs a new presentation
	#
	constructor: ( @parent, view ) ->
		super view ? ( new View.Collection() )

		@_bindKeys( [37, false, false, false], @, @backward )
		@_bindKeys( [39, false, false, false], @, @forward )
		@_bindKeys( [32, false, false, false], @, @present )

		@cursor = $("<div id=\"cursor\"></div>")
		$("body").append(@cursor)

		@_presentation = [null]
		@index = 0

		# Hardcode presentation

		# Set cell name
		@add "#cell_name", "Antidote"

		# Add virus
		@add ".add_metabolite"
		@add ".module-properties.selected .name input", "virus"
		@add ".module-properties.selected .parameter .control-group:contains('amount') input", "100"
		#@add ".module-properties.selected .parameter .control-group:contains('supply') input", "10"
		@add ".module-properties.selected div button:contains('Create')"

		# Transport the virus in

		@add ".add_transporter"
		@add ".module-properties.selected .metabolite .control-group [data-selectable='transported'] label:contains('virus') input"
		@add ".module-properties.selected div button:contains('Create')"

		# Convert the virus to product
		@add ".add_metabolism"
		@add ".module-properties.selected .metabolites .control-group [data-selectable='orig'] input[value='s#int']"
		@add ".module-properties.selected .metabolites .control-group [data-selectable='orig'] input[value='virus#int']"
		@add ".module-properties.selected div button:contains('Create')"
		
		# Add protein
		@add ".add_protein"
		@add ".module-properties.selected div button:contains('Create')"

		# Transport the product out

		@add ".add_transporter:gt(0)"
		@add ".module-properties.selected div button:contains('Create')"
		
		# Simulate the cell

		@add "[data-action='simulate']"

		###

		# Change metabolism velocity

		@add ".metabolism-hitbox"
		@add ".module-properties.selected .parameter .control-group input:gt(3)", "0.5"
		@add ".module-properties.selected div button:contains('Save')"

		###

		# Save the cell

		@add ".btn.dropdown-toggle"
		@add "[data-action='saveAs']"

		# Reset the cell

		@add "[data-action='reset']"
		@add ".modal[aria-hidden='false'] [data-action='confirm']"
		
		# Add virus again

		@add ".add_metabolite"
		@add ".module-properties.selected .name input", "virus"
		@add ".module-properties.selected div button:contains('Create')"
		
		# Load antidote

		@add "[data-action='load']"
		@add "[data-action='load']:gt(0)"
	
	# Add a new slide to move to the id and click or enter an optional value
	#
	# @param selector [String] The DOM selector of the element to present
	# @param value [String] An optional value for the element. If omitted, will click on the element
	#
	add: ( selector, value) ->
		@_presentation.push new Controller.Slide( @, selector, value )
	
	# Moves the presentation backward one step
	#
	backward: ( ) ->
		console.log "Receding presetation"
		@index--
		@jumpToSlide @index
	
	# Moves the presentation forward one step
	#
	forward: ( ) ->
		console.log "Advancing presentation"
		@index++
		@jumpToSlide @index
	
	# Jumps to the slide at the specified index
	#
	jumpToSlide: ( index ) ->
		console.log "Jumping to slide", index
		slide = @_presentation[index]

		if slide?
			done = () =>
				@preparing = off
			@preparing = on
			slide.prepare(done)
		else
			@end()

	# Presents the current slide
	#
	present: ( ) ->
		unless @preparing
			@_presentation[@index]?.present()
	
	# Ends the presentation
	#
	end: ( ) ->
		console.log "Presentation ended"
		@_unbindAllKeys()
