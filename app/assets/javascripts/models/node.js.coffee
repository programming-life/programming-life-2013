# Basic node class
class Node

	# Constructor for node
	#
	# @param object [Object] The object stored in the node
	# @param parent [Node] The parent of this node
	# @param children [Array] An array contraining the children. Default is empty.
	#
	constructor: ( object, parent, children = [] ) -> 
		@_object = object
		@_parent = parent
		@_children = children
		@_branch = null

		@_parent._children.push(this) if @_parent

	# Rebase this branch on a different node than its current parent.
	#
	# @param parent [Node] The new parent for the branch.
	# @return [self] chainable self
	#
	rebase: ( parent ) ->
		parent._children.push this
		parent._branch = this if not parent._branch

		if @_parent is not null
			index = @_parent._children.indexOf(this)
			@_parent._children.splice(index, 1);

		@_parent = parent
		return this

(exports ? this).Node = Node
