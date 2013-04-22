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

		@_parent._children.push(this) if @_parent

(exports ? this).Node = Node
