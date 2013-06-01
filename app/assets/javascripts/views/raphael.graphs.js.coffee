#
#
class View.Graphs extends View.Collection
	
	#
	#
	constructor: ( container = "#graphs" ) ->
		@_container = $( container )
		
		super()
		
