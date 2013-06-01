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
	constructor: ( @object, @parent, children ) -> 
		@id = _.uniqueId('node')
		@branch = null

		@_defineProperties( children )

		@parent?.children.push( this ) 
		@parent?.branch = this

		@_allowEventBindings()
		@_trigger( 'node.creation', @, [] )

	# Define the properties of the node
	#
	# @param children [Array] Initial children of this node
	#
	_defineProperties: ( children = [] ) ->
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

	# Replace this node with a different node
	#
	# @param other [Model.Node] The other node
	# @return [Model.Node] The other node
	#
	replace: ( other ) ->
		index = @parent?.children.indexOf this
		@parent?.children.splice( index, 1 )
		
		for child in @children
			child.parent = other
