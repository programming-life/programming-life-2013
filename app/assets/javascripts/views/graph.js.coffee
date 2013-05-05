# Class to generate graphs from a set of data points
#
class Graph

	# The number of datasets visible
	MAX_DATASETS : 2
	
	_chartOptions:
		pointDot: false
		bezierCurve: false
		scaleShowLabels: true
	
	# Construct a new Graph
	#
	# @param name [String] the name of this graph
	# @param options [Object] the options for the graph
	# @param data [Array] the data for the graph
	# @options options [Integer] width the width of the canvas
	# @options options [Integer] height the height of the canvas
	# @options options [Integer] dt the timestep of the graph
	# @options options [String] fill the CSS colour for the fill
	# @options options [String] stroke the CSS colour for the stroke
	# @options options [String] point.fill the CSS colour for the fill of points
	# @options options [String] point.stroke the CSS colour for the stroke of points
	#
	constructor: ( name, options = {}, data ) ->
		@_canvas = $("<canvas width='#{ options.width ? 450 }' height='#{ options.height ? 200 }'></canvas>")
		@_element = $("<div class='graph'></div>")
		@_element.append $("<h1>#{name}</h1>")
		@_element.append @_canvas
		
		@_datasets = []
		@_nPoints = 0		
		@_dt = options.dt ? 1
			
		@addData( data, options ) if data
		
	# Add a data set to the Graph
	#
	# @param data [Array] an array with data points
	# @param options [Object] the options for the dataset
	# @options options [String] fill the CSS colour for the fill
	# @options options [String] stroke the CSS colour for the stroke
	# @options options [String] point.fill the CSS colour for the fill of points
	# @options options [String] point.stroke the CSS colour for the stroke of points
	# @returns [self] returns self for chaining
	#
	addData: ( data, options = {} ) ->
	
		@_datasets.push
			data: data,
			fill: options.fill ? "rgba(220,220,220,0.5)",
			stroke: options.stroke ? "rgba(220,220,220,1)",
			point: 
				fill : options.point?.fill ? "rgba(220,220,220,1)",
				stroke : options.point?.stroke ? "#fff"

		@_nPoints = data.length if @_nPoints < data.length				
		return this
	
	# Clear all data from the Graph
	#
	# @returns [self] returns self for chaining
	#
	clear: ->
		@_datasets = []
		@_nPoints = 0
		return this

	# Render the Graph into a canvas
	#
	# @param elem [Object] optional: an element to append the Graph's canvas to
	# @returns [Object] returns contained canvas object
	#
	render: ( elem ) ->
		ctx = @_canvas.get(0).getContext("2d")
		
		duration = ( @_nPoints - 1 ) * @_dt
		options = _.clone @_chartOptions

		datasets = _( @_datasets ).last @MAX_DATASETS
		
		# Get maximum and minimum values
		for dataset in datasets
			datamin = _.min dataset.data
			datamax = _.max dataset.data
			min = ( if ( min? ) then Math.min( min, datamin ) else datamin )
			max = ( if ( max? ) then Math.max( max, datamax ) else datamax )
			
		console.log datamin, datamax, min, max

		# Adapt scale if max and min are equal
		if ( max == min )
			options.scaleOverride = true
			options.scaleSteps = 3
			options.scaleStepWidth = 1
			options.scaleStartValue = max - 2
			
			# line will be displayed 1 scaleStep BELOW actual value, so for the
			# time begin, just indicate it didn't change and don't show labels
			options.scaleShowLabels = false 
			 
		labels = for t in [0 ... @_nPoints ] by 1
			''
		labels[ 0 ] = 0
		labels[ labels.length - 1 ] = duration
					
		new Chart( ctx ).Line
			labels: labels
			datasets:
				for dataset in datasets
					data: dataset.data
					fillColor : dataset.fill,
					strokeColor : dataset.stroke,
					pointColor : dataset.point.fill,
					pointStrokeColor : dataset.point.stroke
				
			, options
		
		if elem instanceof jQuery
			elem.append @_element
		
		return @_element
	
	# Return the canvas object
	#
	# @return [Object] the Graph's canvas
	#
	getCanvas: ->		
		return @_canvas
	
	# Return the parent object
	#
	# @return [Object] the Graph's parent object
	#
	getElement: ->
		return @_element
	
	# Set the width en height of the graph
	#
	# @param width [Integer] the width of the canvas
	# @param height [Integer] the height of the canvas
	# @return [self] returns self for chaining
	#
	setDimensions: ( width, height ) ->
		$(@_canvas, @_element).attr('width', width)
		$(@_canvas, @_element).attr('height', height)
		return this


(exports ? this).Graph = Graph