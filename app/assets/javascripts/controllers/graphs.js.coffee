# The controller for the Graphs view
#
class Controller.Graphs extends Controller.Base
	
	# Creates a new instance of graph controller
	#
	# @param view [View.Collection] The view to contain the graphs controller by this
	# @param id [String] A string id for the container of the graphs
	#
	constructor: ( id ) ->
		super new View.Collection( id )

	# Clears the view
	#
	clear: () ->
		@each( ( child, id ) => @removeChild id, on )
		@view.kill()
			
	# Shows the graphs with the data from the datasets
	#
	# @param datasets [Object] An object of datasets
	# @return [Object] graphs
	#
	show: ( datasets, append = off, id = 'id'  ) ->
		template = _.template("graph-<%= #{id} %>") 
		for key, graph of @controllers() when graph instanceof Controller.Graph			
			
			# ( ( key, graph ) => 
			# 	_( =>
			unless datasets[ key ]?
				@view.remove graph.kill().view
				@removeChild key
			# 	).defer()
			# ) key, graph
		
		for key, dataset of datasets
			( ( key, dataset ) => 
				_( =>
					unless @controller( key )?
						id = template({ id: _.uniqueId(), key: key.replace(/#/g, '_') }) 
						graph = new View.Graph( id, key, @view )
						@addChild key, new Controller.Graph( @, graph )
						@view.add graph, false
					@controller( key ).show( dataset, append )
				).defer()
			) key, dataset 

		return this
	
	# Shows the column data for the column where xData is displayed
	#
	# @param xFactor [Float] The relative location of the column to the width of the graph
	#
	showColumnData: ( xFactor ) ->
		@each( (child) -> child.showColumnData( xFactor ) )
			
