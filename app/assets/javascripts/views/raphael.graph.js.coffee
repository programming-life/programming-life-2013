# Class to generate graphs from a set of data points
#
class View.Graph extends View.RaphaelBase

	# Maximum number of simultaneously displayed data sets
	@MAX_DATASETS : 3
	
	@DEFAULTS : 
		smooth: true
		axis: '0 0 1 1'
		#axisxstep: @_dt
		shade : on
		colors: [ "rgba(140, 137, 132, 0.3)",  "rgba(1, 145, 200, 0.5)", "rgba(0, 91, 154, 0.85)" ]
	
	# Construct a new Graph object
	#
	# @param title [String] The title of the graph	
	# @param parent [View.Cell] The cell view this graph belongs to
	#
	constructor: ( @_id = _( 'graph' ).uniqueId() , @_title, parent, container = "#graphs", @_width = 240, @_height = 175 ) ->
		super Raphael( @_id, @_width + 20, @_height + 20), parent
		$( container ).append( @_container = $('<div id="' + @_id + '" class="graph"></div>') )

		@clear()
		@drawTitle()

		@options = _( Graph.DEFAULTS ).clone( true )

	# Add a dataset to visualize in this graphs
	#
	# @param data [Array] An array of datapoints
	# @return [self] chainable self
	#
	addData: ( data ) ->
		@_datasets.unshift data
		return @
	
	# Append a dataset to the most recently added dataset
	#
	# @param data [Array] The data to append
	# @param return [View.Graph] This for easy chaining
	#
	appendData: ( data ) ->
		if @_datasets.length is 0
			@addData data
			return @

		last = _( @_datasets ).first()

		last.xValues.push data.xValues.splice(1)...
		last.yValues.push data.yValues.splice(1)...
		
		return @
		
	# Clears the view
	#
	clear: () ->
		@_chart?.remove()
		@_line?.remove()
		@_line = null
	
	# Draws the graph
	#
	# @param x [Integer] The x coordinate
	# @param y [Integer] The y coordinate
	# @param scale [Integer] The scale
	#
	draw: ( ) ->
		@clear()

		@_drawChart()

	# Draws the chart
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Float] the scale
	# @retun [Raphael] The chart object
	#
	_drawChart:() ->
		xValues = []
		yValues = []

		for i, dataset of _( @_datasets ).first( View.Graph.MAX_DATASETS )
			xValues.unshift dataset.xValues
			yValues.unshift dataset.yValues
		
		options = _( @_options ).clone ( true )
		options.colors = _( options.colors ).last( xValues.length )
		@_chart = @_paper.linechart( 20,0, @_width, @_height ,_( xValues ).clone( true ), _( yValues ).clone( true ), options )


	#	unless @_drawn
	#		@_chart.hoverColumn ( event ) =>
	#			unless @_parent._running
	#				@_parent._drawRedLines( event.x - @_paper.canvas.offsetLeft )
	#	@_drawn = on
	
	# Move the viewbox of the chart
	#
	# @param x [Integer] The amount of pixels to move the viewbox to the right
	#
	moveViewBox: ( x ) ->
		play(x, 10)
	
	# Plays the graphs forward over a timespan
	#
	# @param x [Integer] The x to move to
	# @param time [Integer] The timespan to animate over
	play: ( x = @_width, time = 500 ) ->
		@_paper.animateViewBox(x, 0, @_width, @_height, time)

	# Draws the title
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Float] the scale
	# @return [JQuery] the text object
	#
	drawTitle: ( x, y, scale ) ->
		h2 = $('<h2>'+ @_title + '</h2>')
		@_container.prepend( h2 )

		return h2
	
	# Draws a red line over the chart
	#
	# @param x [Integer] The x position of the line, relative to the offset of the chart
	#
	_drawRedLine: ( x ) ->
		unless @_line?	
			@_line = @_paper
				.path( [ 'M', 0 + x,0, 'V', @_height ] )
				.attr
					stroke : '#F00'
				.toFront()
			@_line.x = x + @_paper.canvas.offsetLeft
			@_line.toFront()
		else
			translation = (x + @_paper.canvas.offsetLeft - @_line.x)
			@_line.x = @_line.x + translation
			@_line.translate( translation )
			@_line.toFront()
