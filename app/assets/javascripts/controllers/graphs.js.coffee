# The controller for the Graphs view
#
class Controller.Graphs extends Controller.Base
	
	# Creates a new instance of graph controller
	#
	# @param view [View.Collection] The view to contain the graphs controller by this
	# @param id [String] A string id for the container of the graphs
	#
	constructor: ( id ) ->
		console.log id
		super new View.Collection( id )
	
	# Shows the graphs with the data from the datasets
	#
	# @param datasets [Object] An object of datasets
	# @return [Object] graphs
	#
	show: ( datasets, append = off, id = 'id'  ) ->
		
		template = _.template("graph-<%= #{id} %>") 
		for key, graph of @controllers() when graph instanceof Controller.Graph
			if not datasets[ key ]?
				@view.remove graph.kill().view
				@removeChild key
		
		for key, dataset of datasets
			unless @controller( key )?
				id = template({ id: _.uniqueId(), key: key.replace(/#/g, '_') }) 
				graph = new View.Graph( id, key, @view )
				@addChild key, new Controller.Graph( graph )
				@view.add graph, false
			@controller( key ).show( dataset, append ) 
		return this
