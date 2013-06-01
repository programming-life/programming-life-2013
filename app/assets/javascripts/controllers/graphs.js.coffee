# The controller for the Graphs view
#
class Controller.Graphs extends Controller.Base
	
	#
	#
	#
	#
	constructor: ( @container = "#graphs" ) ->
		super new View.Graphs( @container )
	