# Class to generate graphs from a set of data points
#
class View.Graph
	
	# @property [Integer] Maximum number of simultaneously displayed data sets
	#
	MAX_DATASETS : 2
	
	# @property [Integer] Maximum length of a set
	#
	MAX_LENGTH : 100
	
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
		
	appendData: ( data ) ->
		
		if @_datasets.length is 0
			addData data
			return @

		@_datasets[ @_datasets.length - 1 ]  = @_datasets[ @_datasets.length - 1 ].concat _( data ).rest()
		return @
		
	# Clears the view
	#
	clear: () ->
		@_contents?.remove()
		@_line?.remove()
		@_line = null
	
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

		# Show the title
		text = @_drawTitle( @_x, @_y, @_scale )
		bbox = text.getBBox()
		@_contents.push text

		# Draw the chart
		set = @_drawChart(@_x, @_y + bbox.height, @_scale)
		@_chart = set[ 0 ]
		@_contents.push set

			
	# Draws the chart
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Float] the scale
	# @retun [Raphael] The chart object
	_drawChart: (x, y, scale ) ->
		
		width = 350
		height = 175
		
		# Only show the last MAX_DATASETS of data
		max = @_datasets.length
		min = Math.max( max - @MAX_DATASETS, 0 )
		datasets = _( @_datasets ).rest min
		
		# Only show the last MAX_LENGTH of xvalues
		for set in datasets
			max = set.length - 1
			min = Math.max( max - @MAX_LENGTH, 0 )
			#console.log "x: #{min} > #{max}"
			xValues = ( num for num in [ min..max ] by 1 )
			
		# Make sure the yvalues are valid
		yValues = _( datasets )
			.chain()
			.map( ( set ) -> 
				set =  _( set ).rest( min )
				set_min = _( set ).min()
			#	console.log "set: #{set_min} > #{_( set ).max()} | diff: #{  _( set ).max() - set_min }"
				return set unless ( diff = Math.abs( _( set ).max() - set_min ) ) < 1e-12
				return [ set_min ] 
			)
			.map( ( set ) ->	
				return set if xValues.length is set.length
				#console.log "y: #{set.length} != #{xValues.length}"
				set_min = _( set ).min()
				while set.length < xValues.length
					set.push set_min
				return set
			).value()

		set = @_paper.set()

		chart = @_paper.linechart( x , y, width, height, xValues, yValues, @_options )
		chart.hoverColumn ( event ) =>
			unless @_parent._running
				@_parent._drawRedLines( event.x - @_x - @_paper.canvas.offsetLeft )

		
		# Draw the gridlines
		lines = @_paper.set()
		for i in [ 0..chart.axis[1].text.items.length - 1 ]
			lines.push( @_paper
				.path( [ 'M', x, chart.axis[1].text.items[i].attrs.y, 'H', width + x ] )
				.attr
					stroke : '#EEE'
				.toBack()
			)

		set.push(chart)
		set.push(lines)
				
		return set
	
	# Draws the title
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Float] the scale
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
