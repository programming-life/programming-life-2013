# Slide for presentation
#
class Controller.Slide extends Controller.Base
	
	# Constructs a new slide
	#
	# @param parent [Controller.Presentation] The presentation this slide belongs to
	# @param selector [String] A DOM selector
	# @param value [Object] An optional value for the element
	#
	constructor: ( @parent, @selector, @argument ) ->
		super( new View.Collection() )

		Object.defineProperty( @, "element",
			get: () => $(@selector).first()
		)
	
	# Prepares the slide
	#
	prepare: ( done ) ->
		console.log "Preparing", @
		@_moveTo @element, done
	
	# Animates the cursor to a specific DOM element
	#
	# @param element [JQuery] The element
	# @param done [Function] Function to execute when done moving
	#
	_moveTo: ( element = @element, done ) ->
		centreX = element.offset().left #+ 10 #(element.width() / 2 )
		centreY = element.offset().top # + 10 #(element.height() / 2 )
		console.log element.width()
		object = {
			top: centreY
			left: centreX
		}
		@parent.cursor.animate(object, 500,"swing", done)
	
	# Inputs a character into an element
	#
	# @param element [JQuery] The element to input into
	# @param char [Character] The character to input
	#
	_inputCharacter: ( element, char ) ->
		element.val( element.val() + char )
	
	# Animates the input of value into element
	#
	_inputValue: ( element, value ) ->
		console.log "Inputting", value, "into", element
		element.val("")
		for i,character of value
			setTimeout( @_inputCharacter, i * 200, element, character )

	
	# Presents this slide
	#
	present: ( ) ->
		console.log "Presenting", @

		@element.select()
		if @argument
			@_inputValue @element, @argument
		else
			console.log @element
			@element.click()
