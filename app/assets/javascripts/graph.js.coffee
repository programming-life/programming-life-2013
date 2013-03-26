# Class to generate graphs from a set of data points

class Graph
	_chartOptions:
		pointDot: false
		bezierCurve: false
	
	# Construct a new Graph
	#
	# @param [Array] an array with data points
	#
	constructor: ( data ) ->
		@_canvas = $("<canvas height='400' width='600'></canvas>")
		@_datasets = []
		@_nPoints = 0		
		
		@addData(data)
		
	# Add a data set to the Graph
	#
	# @param [Array] an array with data points
	# @return [Graph] returns this Graph for chaining
	#
	addData: ( data ) ->
		@_datasets.push(data)
		@_nPoints = data.length if @_nPoints < data.length		
		@	
	
	# Clear all data from the Graph
	#
	# @return [Graph] returns this Graph for chaining
	#
	clear: ->
		@_datasets = []
		@_nPoints = 0
		@

	# Render the Graph into a canvas
	#
	# @param [Object] optional: an element to append the Graph's canvas to
	# @return [Object] returns a canvas object
	#
	render: ( elem ) ->
		ctx = @_canvas.get(0).getContext("2d")
		new Chart(ctx).Line
			labels: 
				t.toFixed(1) for t in [0 .. dt * (@nPoints - 1)] by dt
			datasets:
				for data in @_datasets
					data: data
					fillColor : "rgba(220,220,220,0.5)",
					strokeColor : "rgba(220,220,220,1)",
					pointColor : "rgba(220,220,220,1)",
					pointStrokeColor : "#fff"
			,		
				@_chartOptions
		
		if elem instanceof jQuery
			elem.append(@_canvas)
		
		return @_canvas
	
	# Return the canvas object
	#
	# @return [Object] the Graph's canvas
	#
	getCanvas: ->		
		return @_canvas


(exports ? this).Graph = Graph		
