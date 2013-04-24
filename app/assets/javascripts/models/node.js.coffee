# Basic node class
class Node

	# Constructor for node
	#
	# @param [Object] object The object stored in the node
	# @param [Node] parent The parent of this node
	# @param [Array] children An array contraining the children. Default is empty.
	constructor: ( object, parent, children = [] ) -> 
		@_object = object
		@_parent = parent
		@_children = children
		@_branch = null

		@_parent._children.push(this) if @_parent

	# Rebase this branch on a different node than its current parent.
	#
	# @param [Node] parent The new parent for the branch.
	rebase: ( parent ) ->
		parent._children.push this
		parent._branch = this if not parent._branch

		if @_parent is not null
			index = @_parent._children.indexOf(this)
			@_parent._children.splice(index, 1);

		@_parent = parent
	
	# Remove unnecessary nodes on a the branch starting from this node
	#
	# @returns [Node] The starting node of the node branch.
	# TODO: actually implement
	minimize: ( ) ->
		return this

	# Remove unnecessary nodes on a the branch starting from this node
	#
	# @returns [Node] The starting node of the node branch.
	# TODO: actually implement
	minimize: ( ) ->
		return this

(exports ? this).Node = Node
