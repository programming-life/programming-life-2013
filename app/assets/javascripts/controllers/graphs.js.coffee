# The controller for the Graphs view
#
class Controller.Graphs extends Controller.Base
	
	#
	#
	#
	#
	constructor: ( @container = "#graphs" ) ->
		super new View.Collection()
	
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
				@addChild key, ( graph = new Controller.Graph( @_container, key, @view, 
						template({ id: _.uniqueId(), key: key.replace(/#/g, '_') }) 
				) )
				@view.add graph.view, false
			@controller( key ).show( dataset, append ) 
		return this