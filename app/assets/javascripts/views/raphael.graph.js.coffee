# Class to generate graphs from a set of data points
#
class View.Graph extends View.RaphaelBase
	
	# Maximum number of simultaneously displayed data sets
	@MAX_DATASETS : 2
	
	# Maximum length of a set
	@MAX_LENGTH : 100
	
	# Construct a new Graph object
	#
	# @param title [String] The title of the graph	
	# @param parent [View.Cell] The cell view this graph belongs to
	#
	constructor: ( paper, @_title, @_parent) ->
		@_id = _( 'graph' ).uniqueId() 
		@_container = $('<div id="' + @_id + '" class="graph"></div>')
		@_parent._container.append( @_container )

		@_width = 300
		@_height = 175
		@clear()

		@_paper = Raphael( @_id, @_width + 20, @_height + 20)
		super @_paper 

		@_text = @_drawTitle()

		@_datasets = []

		@_dt = 1
		@_options = {
			smooth: true
			axis: '0 0 1 1'
			#axisxstep: @_dt
			shade : false
			colors: [ "blue", "red", "green", "yellow", "orange" ]
		}

	# Add a dataset to visualize in this graphs
	#
	# @param data [Array] An array of datapoints
	# @return [self] chainable self
	#
	addData: ( data ) ->
		@_datasets.push [[data[0],data[1]]]
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

		_( @_datasets ).last().push [data[0],data[1]]
		
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
		datasets = _( @_datasets ).last()
		@_framesize = datasets[0].length

		xValues = []
		yValues = []

		for i in [0...datasets.length]
			xValues.push datasets[i][0]
			yValues.push datasets[i][1]

			@_chart?.remove()
			@_drawn = off
			@_chart = @_paper.linechart(20,0, (i + 1) * @_width, @_height ,xValues, yValues, @_options )

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
	play: ( x = ( _(@_datasets).last().length - 1) * @_width, time = 500 ) ->
		@_paper.animateViewBox(x, 0, @_width, @_height, time)

	# Draws the title
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Float] the scale
	# @return [JQuery] the text object
	#
	_drawTitle: ( x, y, scale ) ->
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
