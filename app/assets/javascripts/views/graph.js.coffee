# Class to generate graphs from a set of data points
#
class View.Graph
	
	# Maximum number of simultainiously displayed data sets
	#
	MAX_DATASETS : 2
	
	# Construct a new Graph object
	#
	# @param paper [Object] The paper to draw on
	# @param title [String] The title of the graph	
	#
	constructor: ( paper, title, parent) ->
		@_paper = paper
		@_title = title
		@_datasets = []
		@_parent = parent

		@_dt = 1
		@_options = {
			smooth: true
			axis: '0 0 1 1'
			axisxstep: @_dt
			shade : true
			colors: [ "blue", "red" ]
		}
		
	# Add a dataset to visualize in this graphs
	#
	# @param data [Array] An array of datapoints
	# @return [self] chainable self
	#
	addData: ( data ) ->
		@_datasets.push( data )
		return @
		
	# Clears the view
	#
	clear: () ->
		@_contents?.remove()
	
	# Redraw this component with its current parameters
	#
	redraw: () ->
		@draw( @_x, @_y, @_scale )
	
	# Draws the graph
	#
	# @param x [Integer] The x coordinate
	# @param y [Integer] The y coordinate
	# @param scale [Integer] The scale
	#
	draw: ( x, y, scale ) ->
	
		@clear()
				
		@_x = x 
		@_y = y
		@_scale = scale

		@_contents = @_paper.set()

		width = 200 * scale
		height = width * scale

		for set in @_datasets
			xValues = ( num for num in [ 1..set.length ] by 1 )
		yValues = @_datasets
		
		# Show the title
		text = @_drawTitle( x, y, scale )
		bbox = text.getBBox()
		@_contents.push text;
		
		# Draw the chart
		@_chart = @_paper.linechart( x , y + bbox.height, width, height, xValues, yValues, @_options )
		@_chart.hoverColumn ( event ) =>
			@_parent._drawRedLines( event.x - @_chart.getBBox().x - @_paper.canvas.offsetLeft )
		@_chart.mouseout () => 
			console.log("Mouse out")
			@_line?.remove()
			
		@_contents.push @_drawGridLines( x, width )
		@_contents.push @_chart
	
	# Draws the title
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Integer] the scale
	# @return [Raphael] the text object
	#
	_drawTitle: ( x, y, scale ) ->
		text = @_paper.text( x, y, @_title )
		text.attr
			'font-size': 32 * scale
		return text
	
	# Draws the gridlines
	#
	# @param x [Integer] the x position
	# @param width [Integer] the width
	# @return [Raphael] the lines object
	#
	_drawGridLines: ( x, width ) ->
	
		lines = @_paper.set()
		for i in [ 0..@_chart.axis[1].text.items.length - 1 ]
			lines.push( @_paper
				.path( [ 'M', x, @_chart.axis[1].text.items[i].attrs.y, 'H', width + x ] )
				.attr
					stroke : '#EEE'
				.toBack()
			)
				
		return lines
	
	# Draws a red line over the chart
	#
	# @param x [Integer] The x position of the line, relative to the offset of the chart
	#
	_drawRedLine: ( x ) ->
		@_line?.remove()
		
		bbox = @_chart.getBBox()
		@_line = @_paper
			.path( [ 'M', x + bbox.x, bbox.y, 'V', @_chart.axis[0].text.items[0].attrs.y] )
			.attr
				stroke : '#F00'
			.toFront()
		
		@_contents.push @_line

(exports ? this).View.Graph = View.Graph