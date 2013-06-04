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
	constructor: ( @container, title, parentview, id = _( 'graph-' ).uniqueId() ) ->
		super new View.Graph( id, title, parentview, @container )
	
		@_datasets = []
		
	# Add a dataset to visualize in this graphs
	#
	# @param data [Array] An array of datapoints
	# @return [self] chainable self
	#
	add: ( data ) ->
		@_datasets.unshift data
		return @
	
	# Append a dataset to the most recently added dataset
	#
	# @param data [Array] The data to append
	# @return [self] chainable self
	#
	append: ( data ) ->
		if @_datasets.length is 0
			@addData data
			return @

		last = _( @_datasets ).first()

		last.xValues.push data.xValues.splice(1)...
		last.yValues.push data.yValues.splice(1)...
		return @
		
	#
	#
	show: ( dataset, append ) ->
		@add dataset unless append
		@append dataset if append
		@view.draw @_datasets