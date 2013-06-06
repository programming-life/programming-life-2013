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
				id = template({ id: _.uniqueId(), key: key.replace(/#/g, '_') }) 
				view = new View.Graph( id, key, @view, @_container )
				@addChild key, new Controller.Graph( view )
				@view.add view, false
			@controller( key ).show( dataset, append ) 
		return this
