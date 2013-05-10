# Class to generate graphs from a set of data points
#
class View.Graph2
	
	MAX_DATASETS : 2
	
	# Construct a new Graph object
	#
	# @param paper [Object] The paper to draw on
	# @param title [String] The title of the graph	
	constructor: ( paper, title) ->
		@_paper = paper
		@_title = title
		@_datasets = []

		@_dt = 1
		@_options = {
			smooth: true
			axis: '0 0 1 1'
			axisxstep: @_dt
			shade : true
			colors: ["blue", "green"]
		}
		
	# Add a dataset to visualize in this graphs
	#
	# @param data [Array] An array of datapoints
	#
	addData: ( data ) ->
		@_datasets.push(data)
		return @
	
	# Redraw this component with its current parameters
	#
	redraw: () ->
		@_contents?.remove()
		@draw(@_x, @_y, @_scale)
	
	# Draws the graph
	#
	# @param x [Integer] The x coordinate
	# @param y [Integer] The y coordinate
	# @param scale [Integer] The scale
	#
	draw: ( x, y, scale ) ->
		@_x = x 
		@_y = y
		@_scale = scale

		@_contents = @_paper.set()

		@_width = 400 * @_scale
		@_height = @_width * @_scale

		for set in @_datasets
			xValues = (num for num in [1..set.length] by 1)
		yValues = @_datasets
		
		@_text = @_paper.text( @_x, @_y, @_title )
		@_text.attr
			'font-size': 42 * @_scale
		
		@_contents.push @_text
		
		bbox = @_text.getBBox()

		@_chart = @_paper.linechart(@_x , @_y + bbox.height, @_width, @_height, xValues, yValues, @_options)
		@_chart.mouseout () => 
			console.log("Mouse out")
			@_line?.remove()
		@_drawGridLines()
		@_contents.push(@_chart)
	
	_drawGridLines: ( ) ->
		# Draw horizontal gridlines
		for i in [0..@_chart.axis[1].text.items.length - 1]
			@_paper.path(['M', @_x, @_chart.axis[1].text.items[i].attrs.y, 'H', @_width + @_x]).attr({
				stroke : '#EEE'
			}).toBack();
		
	
	_drawRedLine: ( x, y ) ->
		@_line?.remove()
		chartY = @_chart.getBBox().y
		@_line = @_paper.path(['M', x, chartY, 'V', @_chart.axis[0].text.items[0].attrs.y]).attr({
			stroke : '#F00'
		}).toFront();
		
		@_contents.push(@_line)

(exports ? this).View.Graph2 = View.Graph2
