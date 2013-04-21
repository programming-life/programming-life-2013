# Class to generate graphs from a set of data points
#
class Graph

	_chartOptions:
		pointDot: false
		bezierCurve: false
		scaleShowLabels: true
	
	# Construct a new Graph
	#
	# @param [String] name the name of this graph
	# @param [Array] options the options for the graph
	# @param [Array] data the data for the graph
	# @param [Integer] dt the timestep
	#
	constructor: ( name, options = {}, data ) ->
		@_canvas = $("<canvas width='#{ options.width ? 400 }' height='#{ options.height ? 200 }'></canvas>")
		@_element = $("<div class='graph'></div>")
		@_element.append $("<h1>#{name}</h1>")
		@_element.append @_canvas
		
		@_datasets = []
		@_nPoints = 0		
		@_dt = options.dt ? 1
			
		@addData( data ) if data
		
	# Add a data set to the Graph
	#
	# @param [Array] data an array with data points
	# @param [Object] options the options for the dataset
	# @returns [self] returns self for chaining
	#
	addData: ( data, options = {} ) ->
		console.info( data )
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
	# @param [Object] optional: an element to append the Graph's canvas to
	# @returns [Object] returns contained canvas object
	#
	render: ( elem ) ->
		ctx = @_canvas.get(0).getContext("2d")
		
		duration = @_nPoints * @_dt
		options = _.clone @_chartOptions

		# This is a temporary fix to show lines which are horizontal. 
		
		# Get maximum and minimum values
		for dataset in @_datasets
			datamin = _.min dataset.data
			datamax = _.max dataset.data
			min = ( if ( min? ) then Math.min( min, datamin ) else datamin )
			max = ( if ( max? ) then Math.max( max, datamax ) else datamax )

		# Adapt scale if max and min are equal
		if ( max == min )
			options.scaleOverride = true
			options.scaleSteps = 3
			options.scaleStepWidth = 1
			options.scaleStartValue = max - 2
			
			# line will be displayed 1 scaleStep BELOW actual value, so for the
			# time begin, just indicate it didn't change and don't show labels
			options.scaleShowLabels = false 
			 
		
		new Chart( ctx ).Line
			labels: 
				for t in [0 ... duration] by @_dt
					if ( 0 < t < duration - @_dt ) then '' else t
			datasets:
				for dataset in @_datasets
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
	# @return [self] returns self for chaining
	#
	setDimensions: ( width, height ) ->
		$(@_canvas, @_element).attr('width', width)
		$(@_canvas, @_element).attr('height', height)
		return this


(exports ? this).Graph = Graph