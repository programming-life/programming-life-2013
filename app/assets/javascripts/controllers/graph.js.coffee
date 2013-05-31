# The controller for the Graph view
#
class Controller.Graph extends Controller.Base
	
	# Maximum number of simultaneously displayed data sets
	@MAX_DATASETS : 3
	
	# Maximum length of a set
	@MAX_LENGTH : 100
	
	#
	#
	#
	#
	constructor: ( title, @container) ->
		super new View.Graph( undefined, title, undefined, @container )
	
		@_datasets = []
		