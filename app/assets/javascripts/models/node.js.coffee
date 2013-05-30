# Basic node class
#
# @concern Mixin.EventBindings
#
class Model.Node extends Helper.Mixable

	@concern Mixin.EventBindings

	# Constructor for node
	#
	# @param object [Object] The object stored in the node
	# @param parent [Node] The parent of this node
	# @param children [Array] An array contraining the children. Default is empty.
	#
	constructor: ( @object, @_parent, children ) -> 
		@id = _.uniqueId('node')
		@branch = null

		@_defineProperties( children )

		@_parent?.children.push( this ) 
		@_parent?.branch = this

		@_allowEventBindings()
		@_trigger( 'node.creation', @, [] )
		console.log(@)

	# Define the properties of the node
	#
	# @param children [Array] Initial children of this node
	#
	_defineProperties: ( children = [] ) ->
		Object.defineProperty( @, "parent",
			get: () -> return @_parent
			set: ( value ) ->
				@_parent = value
				value.children.push this
				value.branch = this
		)
		Object.defineProperty( @, "children",
			value: children
			writable: off
			configurable: off
		)
		Object.defineProperty( @, "creation",
			value: new Date()
			writable: off
			configurable: off
		)
	
	# Add a child to this node
	#
	# @param object [Object] The object to be contained in the child
	# @return [Model.Node] The created node
	#
	addChild: ( object ) ->
		node = new Model.Node(object, this)
		return node

	# Rebase this branch on a different node than its current parent.
	#
	# @param parent [Node] The new parent for the branch.
	# @return [self] chainable self
	#
	rebase: ( parent ) ->
		index = @parent?.children.indexOf this
		@parent?.children.splice( index, 1 )
		@parent = parent

		return this
	
	# Replace this node with a different node
	#
	# @param other [Model.Node] The other node
	# @return [Model.Node] The other node
	#
	replace: ( other ) ->
		other.parent = @parent

		if @parent?
			index = @parent.children.indexOf this
			@parent.children.splice( index, 1 )
		
		for child in @children
			child.parent = other
		
		other.branch = @branch
