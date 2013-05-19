# Basic node class
#
class Model.Node

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
		@_creation = new Date()

		@_parent._children.push( this ) if @_parent

		Model.EventManager.trigger( 'node.creation', @, [] )

	# Rebase this branch on a different node than its current parent.
	#
	# @param parent [Node] The new parent for the branch.
	# @return [self] chainable self
	#
	rebase: ( parent ) ->
		parent._children.push this
		parent._branch = this if not parent._branch

		if @_parent isnt null
			index = @_parent._children.indexOf this
			@_parent._children.splice( index, 1 )

		@_parent = parent
		return this
	
	# Replace this node with a different node
	#
	# @param other [Model.Node] The other node
	# @return [Model.Node] The other node
	#
	replace: ( other ) ->
		other._branch = @_branch unless other._branch

		if @_parent?._branch is this
			@_parent._branch = other
		
		other._children.push @_children...

		if @_parent?
			index = @_parent._children.indexOf this
			@_parent._children.splice( index, 1 )
		
		for child in @_children
			child._parent = other
