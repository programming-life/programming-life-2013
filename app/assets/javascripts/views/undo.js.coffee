# View for undo functionality
#
class View.Undo extends Helper.Mixable
	
	@concern Mixin.TimeMachine
	@concern Mixin.EventBindings

	# Creates a new instance of this view
	#
	# @param container [Object] The DOM node to contain this view
	# @param tree [Model.UndoTree] The UndoTree to visualize
	#
	constructor: ( @_container, @_tree ) ->
		@_allowEventBindings()

		@_bind("tree.add.node", this, @_onNodeAdd)
		@_bind("tree.remove.node", this, @_onNodeRemove)
	
	# Kills this view
	#
	kill: ( ) ->
		@_parent?.remove()


	# Clears this view
	#
	clear: ( ) ->
		@_contents?.remove()
	
	# Redraws this view
	#
	redraw: ( ) ->
		@draw()
	
	resize: ( ) ->
		@draw()

	# Draws this view
	#
	# @param container [Object] The DOM node to contain this view
	#
	draw: ( @_container = @_container ) ->
		@clear()

		# Create the popover
		@_contents = $('<div class="undo"></div>')

		# Create the popover header
		@_header = $('<h2></h2>')
		@_contents.append(@_header)

		@_header.append("Action history")

		# Create the popover body
		@_body = $('<dl class="undo-list"></dl>')
		@_contents.append(@_body)

		# Create body content and append to body
		@_populateBody()

		@_container.append(@_contents)

	# Populates the body of the list with the items
	#
	_populateBody: ( ) ->
		node = @_tree._root
		while node?
			alternatives = 0
			if node._parent? 
				alternatives = node._parent._children.length - 1

			element = $(
				'<dl>'+
					'<dt>'+node._object._description+'</dt>'+
					'<dd>'+alternatives+' alternative actions</dd>'+
				'</dl>'
			)
			element.click( node, (event) =>
				@_onClick( event.data )
			)
			if node is @_tree._current
				element.css("border","2px solid #009ACD")
			@_body.append(element)
			node = node._branch
	
	_onNodeAdd:( tree, node ) ->
		if tree is @_tree
			@draw()

	_onNodeRemove:( tree, node ) ->
		if tree is @_tree
			@draw()
	
	_onClick: ( node ) ->
		nodes = @_tree.jump( node )
		for undo in nodes.reverse
			undo._object.undo()
		for redo in nodes.forward
			redo._object.redo()
		@draw()


(exports ? this).View.Undo = View.Undo
