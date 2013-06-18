# Tree with explicit undo and redo functionality
#
class Model.UndoTree extends Model.Tree

	# Constructs a new undotree.
	#
	# @param [Node] root The root node of the tree. Default is Node(null, null).
	#
	constructor: ( root ) ->
		super(root)
	
	# Has added a new node containing the object to the current branch of the tree.
	#
	# @param [Object] object The object to add to the tree.
	# @return [Node] The node containing the object.
	#
	add: ( object ) ->
		@current = super( object, @current)
		return @current
	
	# Moves the pointer to the active node of the current branch back a step.
	#
	# @return [Object, null] The object contained within the most recent active node.
	#
	undo: ( ) ->
		if @current isnt @root
			object = @current.object
			@current = @current.parent
			return object
		else
			return null
	
	# Move the pointer to the active node of the current branch forward a step.
	#
	# @return [Object, null] The object contained within the now active node.
	#
	redo: ( ) ->
		if @current.branch isnt null
			@current = @current.branch
			object = @current.object
			return object
		else
			return null
	
	# Rebase a branch on a different node than it's current parent.
	#
	# @param [Node] branch The branch to rebase.
	# @param [Node] new The new parent for the branch.
	# @return [self] Chainable self
	#
	rebase: ( branch, parent) ->
		branch.parent = parent
		if branch is @root
			@root = parent

		return this
	
	# Rewinds the tree from the current node and up to the node to jump to
	#
	# @param [Model.Node] The node to jump to
	# @return [Object] An object containing two arrays of the nodes, in order of steps from the current node to the node to jump to
	jump: ( node ) ->
		todo = []
		undo = []

		# Behind the current node
		if node.creation < @current.creation
			undo = @_getReverseTrail( node )
		# In front of current node
		else if node.creation > @current.creation
			todo = @_getForwardTrail( node, @current )

		@current = node

		return {reverse: undo, forward: todo}
	
	# Returns the path from the current node to the given node
	#
	# @param node [Model.Node] The node to get the path to
	#
	_getReverseTrail: ( node ) ->
		undo = []
		
		back = @current
		until (back is node or back is @root)
			undo.push back
			back = back.parent
		
		return undo
		
	# Returns the path from the base node to the given node, assuming it's on the current branch
	#
	# @param node [Model.Node] The node to get the path to
	#
	_getForwardTrail: ( node, base = @ ) ->
		todo = []
		forward = base 
		until forward is node or forward.branch is null
			forward = forward.branch
			todo.push forward
		return todo
	
		
	
