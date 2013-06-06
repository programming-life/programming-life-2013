# The controller for the Graph view
#
class Controller.Graph extends Controller.Base
	
	# Maximum number of simultaneously displayed data sets
	@MAX_DATASETS : 3
	
	# Maximum length of a set
	@MAX_LENGTH : 100
	
	# Constructs a new graph controller
	#
	# @param view [View.Graph] The view to control
	#
	constructor: ( view ) -> #@container, title, parentview, id = _( 'graph-' ).uniqueId() ) ->
		super view #new View.Graph( id, title, parentview, @container )
	
		@_datasets = []
		@_automagically = on
		
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
			@add data
			return @

		newest = _( @_datasets ).first()

		newest.xValues.push data.xValues...
		newest.yValues.push data.yValues...
		return @
		
	# Shows a dataset in the graph view
	#
	# @param dataset [Object] An object containing an xValues and yValues array
	# @param append [Boolean] Whether to append the dataset or add it as a new dataset
	#
	show: ( dataset, append = false ) ->
		console.log dataset
		if @_automagically and append
			dataset.xValues = dataset.xValues.splice(1)
			dataset.yValues = dataset.yValues.splice(1)

		@add dataset unless append
		@append dataset if append
		@view.draw @_datasets
