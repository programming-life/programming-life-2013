# Basic tree class
#
class Tree
	# Constructor for tree
	#
	# @param [Node] root The root node of the tree
	#
	constructor: ( root = new Node( null, null ) ) -> 
		@_root = root
		@_current = @_root
	
	# Add an object to the tree
	#
	# @param object [Object]  The object to add to the tree
	# @param parent [Node] The future parent
	# @return [Node] the added node
	#
	add: ( object, parent = @_root ) ->
		node = new Node(object, parent)
		current = node
		while parent isnt null
			parent._branch = current
			parent = parent._parent
		return node
	
	# Find an objects location in the tree
	#
	# @param [Object] object The object to find
	# @param [Node] start The node to start searching from. Default is root
	# @return [Node] The node containing the object or null if it doesn't exist.
	#
	find: ( object, start = @_root ) ->
		return start if object is start._object
		for child in start._children
			res = @find( object, child)
			return res if res
		return null
		
(exports ? this).Tree = Tree
