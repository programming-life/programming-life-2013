# Adds presentation functionality to it's parent
#
class Controller.Presentation extends Controller.Base
	
	# Constructs a new presentation
	#
	constructor: ( @parent, view ) ->
		super view ? ( new View.Collection() )
		@_bindKeys( [39, false, false, false], @, @forward )
	
	# Moves the presentation forward one step
	#
	forward: ( ) ->
