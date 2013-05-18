# Class to generate graphs from a set of data points
#
class View.Graph extends View.RaphaelBase
	
	# @property [Integer] Maximum number of simultaneously displayed data sets
	#
	MAX_DATASETS : 2
	
	# @property [Integer] Maximum length of a set
	#
	MAX_LENGTH : 100
	
	# Construct a new Graph object
	#
	# @param title [String] The title of the graph	
	# @param parent [View.Cell] The cell view this graph belongs to
	#
	constructor: ( paper, @_title, @_parent) ->
		@_container = $('<div class="graph-container"></div>')
		@_width = 300
		@_height = 200
		console.log("constructor")
		@clear()
		@_paper = @_getPaper()
		super(@_paper)

		@_datasets = []

		@_dt = 1
		@_frame = [0,20]
		@_options = {
			smooth: true
			axis: '0 0 1 1'
			axisxstep: @_dt
			shade : false
			colors: [ "blue", "red" ]
		}

	# Add a dataset to visualize in this graphs
	#
	# @param data [Array] An array of datapoints
	# @return [self] chainable self
	#
	addData: ( data ) ->
		@_datasets.push data
		return @
	
	# Append a dataset to the most recently added dataset
	#
	# @param data [Array] The data to append
	# @param return [View.Graph] This for easy chaining
	appendData: ( data ) ->
		
		if @_datasets.length is 0
			addData data
			return @

		lastX = _( @_datasets[ @_datasets.length - 1 ][0] ).last()
		for x in data[0]
			@_datasets[ @_datasets.length - 1 ][0].push (x + lastX)
		@_datasets[ @_datasets.length - 1 ][1]  = @_datasets[ @_datasets.length - 1 ][1].concat _( data[1] ).rest()
		#@_frame = [@_frame[0] + 20, @_frame[1] + 20]
		
		return @
		
	# Clears the view
	#
	clear: () ->
		@_container.empty()
		@_container.remove()
		@_paper?.remove()
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

		@_container = $('<div class="graph-container"></div>')

		@_paper = @_getPaper()

		@_drawChart(@_frame)

		@_drawTitle()

		@_parent._container.append @_container
	
	# Gets a new paper in the container for this graph
	#
	# @return [Object] A new paper
	#
	_getPaper: ( ) ->
		paper = Raphael( @_container[0], @_width, @_height)
		return paper
			
	# Draws the chart
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Float] the scale
	# @retun [Raphael] The chart object
	#
	_getValues: (frame = @_frame) ->
		# Only show the last MAX_DATASETS of data
		max = @_datasets.length
		min = Math.max( max - @MAX_DATASETS, 0 )
		datasets = _( @_datasets ).rest min

		# Make sure the yvalues are valid
		yValues = _( datasets )
			.chain()
			.map( ( set ) -> 
				set =  _( set ).rest( min )
				set_min = _( set ).min()
				return set unless ( diff = Math.abs( _( set ).max() - set_min ) ) < 1e-12
				return [ set_min ] 
			)
			.map( ( set ) ->	
				return set if xValues.length is set.length
				set_min = _( set ).min()
				while set.length < @MAX_LENGTH
					set.push set_min
				return set
			).value()

		return [xValues, yValues]


	_drawChart:(frame = @_frame) ->
		[xValues,yValues] = _( @_datasets ).last()
		chart = @_paper.linechart(0,0,300,175,xValues, yValues, @_options )
		#chart.hoverColumn ( event ) =>
		#	unless @_parent._running
		#		@_parent._drawRedLines( event.x - @_x - @_paper.canvas.offsetLeft )
	
	# Draws the title
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Float] the scale
	# @return [Raphael] the text object
	#
	_drawTitle: ( x, y, scale ) ->
		h2 = $('<h2>'+ @_title + '</h2>')
		@_container.prepend( h2 )

		return h2
	
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
		unless @_line?	
			@_line = @_paper
				.path( [ 'M', x + @_x, @_y, 'V', @_chart.axis[0].text.items[0].attrs.y] )
				.attr
					stroke : '#F00'
				.toFront()
			@_line.x = x + @_x + @_paper.canvas.offsetLeft
			@_line.toFront()
		else
			translation = (x + @_x + @_paper.canvas.offsetLeft - @_line.x)
			@_line.x = @_line.x + translation
			@_line.translate( translation )
			@_line.toFront()

(exports ? this).View.Graph = View.Graph
