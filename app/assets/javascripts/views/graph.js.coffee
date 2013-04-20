# Class to generate graphs from a set of data points

class Graph
	_chartOptions:
		pointDot: false
		bezierCurve: false
		scaleShowLabels: false
	
	# Construct a new Graph
	#
	# @param [String] the name of this graph
	#
	constructor: ( name, data ) ->
		@_canvas = $("<canvas></canvas>")
		@_element = $("<div class='graph'></div>")
		@_element.append(@_canvas)
		
		@_datasets = []
		@_nPoints = 0		

		@addData( data ) if data
		
	# Add a data set to the Graph
	#
	# @param [Array] an array with data points
	# @return [self] returns self for chaining
	#
	addData: ( data ) ->
		@_datasets.push(data)
		@_nPoints = data.length if @_nPoints < data.length		
		@	
	
	# Clear all data from the Graph
	#
	# @return [self] returns self for chaining
	#
	clear: ->
		@_datasets = []
		@_nPoints = 0
		@

	# Render the Graph into a canvas
	#
	# @param [Object] optional: an element to append the Graph's canvas to
	# @return [Object] returns contained canvas object
	#
	render: ( elem ) ->
		ctx = @_canvas.get(0).getContext("2d")
		
		xsize = dt * ( @_nPoints )
		xnum = Math.min( xsize / dt, 8 )
		xstep = xsize / xnum
		
		new Chart(ctx).Line
			labels: 
				 t.toFixed 1 for t in [0 .. xsize] by xstep #TODO change this to maximum number
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
			elem.append(@_element)
		
		@_element
	
	# Return the canvas object
	#
	# @return [Object] the Graph's canvas
	#
	getCanvas: ->		
		@_canvas
	
	# Return the parent object
	#
	# @return [Object] the Graph's parent object
	#
	getElement: ->
		@_element
	
	# Set the width en height of the graph
	#
	# @return [self] returns self for chaining
	#
	setDimensions: ( width, height ) ->
		$(@_canvas, @_element).attr('width', width)
		$(@_canvas, @_element).attr('height', height)
		@


(exports ? this).Graph = Graph		
