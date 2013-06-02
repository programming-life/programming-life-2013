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
		@_createChildren()
		@_createBindings()
		
		@load( cell_id )
		
		
	# Creates children
	#
	_createChildren: () ->
		@addChild 'cell', new Controller.Cell( @view.paper, @view, undefined, off )
		@addChild 'graphs', new Controller.Graphs( @view.paper )
		
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
		
	# Solve the system
	#
	# @return [Tuple<CancelToken, jQuery.Promise>] a token and the promise
	#
	solveTheSystem: () ->
		
		@_iterations = 2
		@_currentIteration = 0
	
		iterationDone = ( results, from, to ) =>
			@controller( 'graphs' ).show( results.datasets, @_currentIteration > 0, 'key' )
			@_currentIteration++
			@_setProgressBar 0

		@view.showProgressBar()
		[ token, promise ] = @controller('cell').startSimulation( 20, @_iterations, iterationDone )
		promise.done () => $('#create-pdf').removeProp 'disabled'
		promise.done () => @view.hideProgressBar()
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
		
	