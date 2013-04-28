# Tree with explicit undo and redo functionality
class UndoTree extends Tree

	# Constructs a new undotree.
	#
	# @param [Node] root The root node of the tree. Default is Node(null, null).
	constructor: ( root ) ->
		super(root)
	
	# Has added a new node containing the object to the current branch of the tree.
	#
	# @param [Object] object The object to add to the tree.
	# @returns [Node] The node containing the object.
	add: ( object ) ->
		for child in @_current._children
			@_current = child if child._object is object

		@_current = super( object, @_current)
		return @_current
	
	# Moves the pointer to the active node of the current branch back a step.
	#
	# @returns The object contained within the most recent active node.
	undo: ( ) ->
		if @_current isnt @_root
			object = @_current._object
			@_current = @_current._parent
			return object
		else
			return null
	
	# Move the pointer to the active node of the current branch forward a step.
	#
	# @returns The object contained within the now active node.
	redo: ( ) ->
		if @_current._branch isnt null
			@_current = @_current._branch
			object = @_current._object
			return object
		else
			return null
	
	# Rebase a branch on a different node than it's current parent.
	#
	# @param [Node] branch The branch to rebase.
	# @param [Node] new The new parent for the branch.
	rebase: ( branch, parent) ->
		branch.rebase(parent)
		if branch is @_root
			@_root = parent
			
(exports ? this).UndoTree = UndoTree
