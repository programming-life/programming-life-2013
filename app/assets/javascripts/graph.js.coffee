class Graph
	###
	Generic graphing class. Will take a set of data points and display them on a canvas.
	###

	chartOptions:
		pointDot: false
		bezierCurve: false
	
	constructor: (data) ->
		### 
		Creates a new graph. Takes a one dimensional array of datapoints. 
		###
		
		@canvas = $("<canvas height='400' width='600'></canvas>")
		@datasets = []
		@nPoints = 0		
		@addData(data)
		
	addData: (data) ->
		### 
		Adds a dataset to the graph. Takes a one dimensional array of datapoints.	
		###
		
		@datasets.push(data)
		@nPoints = data.length if @nPoints < data.length		
		return this		
		
	clear: ->
		###
		Clears all current datasets from the graph.
		###
	
		@datasets = []
		return this

	render: (elem) ->
		###
		Renders the graph and returns a canvas element containing it. 
		Optionally takes a jQuery object as argument and if set, will append the graph to it.
		###		
		
		ctx = @canvas.get(0).getContext("2d")
		new Chart(ctx).Line
			labels: 
				t.toFixed(1) for t in [0 .. dT * (@nPoints - 1)] by dT
			datasets:
				for data in @datasets
					data: data
					fillColor : "rgba(220,220,220,0.5)",
					strokeColor : "rgba(220,220,220,1)",
					pointColor : "rgba(220,220,220,1)",
					pointStrokeColor : "#fff"
			,		
				@chartOptions
		
		if elem instanceof jQuery
			elem.append(@canvas)
		
		return @canvas
		
	getCanvas: ->
		###
		Returns the graph's canvas. May be empty.
		###
		
		return @canvas


(exports ? this).Graph = Graph		
