# Basic tree class
#
class Model.Tree extends Helper.Mixable

	@LeftBranch: -1
	@RightBranch: 1

	
	@concern Mixin.EventBindings
	
	# Constructor for tree
	#
	# @param [Node] root The root node of the tree
	#
	constructor: ( @root = new Model.Node() ) -> 
		@current = @root
		@_allowEventBindings()


	# Set a new root for the tree
	#
	# @param root [Model.Node] The new root
	#
	setRoot: ( root ) ->
		if @current is @root
			@current = root

		@root = root
		@root.replace( root )
	
	# Add an object to the tree
	#
	# @param object [Object]  The object to add to the tree
	# @param parent [Node] The future parent
	# @return [Node] the added node
	#
	add: ( object, parent = @current ) ->
		node = parent.addChild( object )
		@current = node

		@_trigger( "tree.node.added", this, [ node ])

		return node
	
	# Add a node to the tree
	#
	# @param node [Model.Node] The node to add.
	# @param parent [Model.Node] The new parent of the node.
	#
	addNode: ( node, parent = @current ) ->
		node.parent = parent
		parent.branch = node
		parent.children.push node
		@current = node
		return node
	
	# Find an objects location in the tree
	#
	# @param [Object] object The object to find
	# @param [Node] start The node to start searching from. Default is root
	# @return [Node] The node containing the object or null if it doesn't exist.
	#
	find: ( object, start = @root ) ->
		return start if object is start.object
		for child in start.children
			res = @find( object, child)
			return res if res?
		return null
	
	# A wrapper method the breadthfirst iterator	
	#
	# @return [Array] The resuls of breadthfirst()
	iterator: ( ) ->
		return @breadthfirst()
	
	# Returns a breadthfirst itarator array for the tree
	#
	# @param start [Model.Node] The root of the iterator
	# @return [Array] An array with the nodes of the tree in breadthfirst order
	breadthfirst: ( start = @root ) ->
		res = [start]

		res.push start.children...

		for child in start.children
			arr = @breadthfirst(child)
			arr.splice(0,1)
			res.push arr...

		return res
	
	# Returns a depthfirst itarator array for the tree
	#
	# @param start [Model.Node] The root of the iterator
	# @return [Array] An array with the nodes of the tree in depthfirst order
	depthfirst: ( start = @root ) ->
		res = [start]

		for child in start.children
			res.push @depthfirst(child)...

		return res
	
	# Switches the branch of the tree to contain the node
	#
	# @param node [Model.Node] The node to switch the branch to
	# @retun [Model.Node] The old branch
	#
	switchBranch: ( node ) ->
		old = @current
		if node.parent?
			node.parent.branch = node
			@current = node
		return old
