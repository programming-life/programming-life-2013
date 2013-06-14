#
#
class Controller.Report extends Controller.Base

	# Creates a new instance of Main
	#
	# @param container [String, Object] A string with an id or a DOM node to serve as a container for the view
	# @param view [View.Report] the view for this controller
	#
	constructor: ( cell_id, @container = "#paper", view ) ->
	
		super view ? new View.Report( @container )
		
		@_currentIteration = 0
		@_datasets = {}
		@_createChildren()
		@_createBindings()
		
		@load( cell_id )
		
		
	# Creates children
	#
	_createChildren: () ->
		@addChild 'cell', new Controller.Cell( @view.paper, @view, undefined, off )
		@addChild 'graphs', new Controller.Graphs( @view.paper )
		@addChild 'settings', new Controller.Settings()
		
		@view.add @controller('cell').view
		@view.add @controller('graphs').view
		
	#
	#
	_createBindings: () ->
		#@view.bindActionButtonClick( () => @onAction( arguments... ) ) 
		
	# Sets the progress bar
	#
	# @param value [Integer] the current value
	#
	_setProgressBar: ( value ) =>
		@view.setProgressBar value / @_iterations + 1 / @_iterations * @_currentIteration
		return this

	# Loads a new cell into the report view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback ) ->
		@view.draw()
		
		promise = @controller('cell').load cell_id, callback
		promise.done( () => 
			@serializePaper()
			@solveTheSystem()
		)
			
		return promise
		
	# Serializes a paper
	#
	# @return [String] the serialized paper in XML
	#
	serializePaper: () ->
		cell_svg = new XMLSerializer().serializeToString @view.paper.canvas
		$( '#report_data' ).attr( "value", cell_svg )
		return cell_svg
		
	# Serializes the graph datasets
	#
	# @return [JSON] the serialized datasets
	#
	serializeDatasets: () ->
		serializedDatasets = JSON.stringify( @_datasets )
		$( '#report_datasets' ).attr( "value", serializedDatasets )
		return serializedDatasets

	# Solve the system
	#
	# @return [Tuple<CancelToken, jQuery.Promise>] a token and the promise
	#
	solveTheSystem: () ->
		
		@_iterations = @controller('settings').options.simulate.iterations
		@_currentIteration = 0

		iterationDone = ( results, from, to ) =>
			@controller( 'graphs' ).show( results.datasets, @_currentIteration > 0, 'key' )
			
			# Send first dataset only for now, second dataset is bugged
			@_datasets = results.datasets if @_currentIteration == 0

			@_currentIteration++
			@_setProgressBar 0

		@view.showProgressBar()
		settings = @controller('settings').options
		override = { dt: 0.01, interpolate: on }
		[ token, promise ] = @controller('cell').startSimulation( settings.simulate, iterationDone, _( override ).defaults (settings.ode) )
		promise.done( () => 
			$('#create-pdf').removeProp 'disabled'
			$('#create-csv').removeProp 'disabled'
			@view.hideProgressBar()
			@serializeDatasets()
		)
		promise.progress @_setProgressBar
		
	# Runs on an action (click)
	#
	# @param event [jQuery.Event] the event
	#
	onAction: ( event ) =>
		
		target = $( event.currentTarget )
		action = target.data( 'action' )
		action = action.charAt(0).toUpperCase() + action.slice(1)
		
		@[ 'on' + action ]?( target, enable, success, error )
		
	