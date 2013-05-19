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

		@_leftButton = $('<span class="btn btn-left">&lt;</span>').click( () =>
			@_onClickLeftButton()
		)
		@_header.prepend(@_leftButton)
		@_rightButton = $('<span class="btn btn-right">&gt;</span>').click( () =>
			@_onClickRightButton()
		)
		@_header.append(@_rightButton)

		# Create the popover body
		@_body = $('<dl class="undo-list"></dl>')
		@_contents.append(@_body)

		@_body.append(@_getView( @_tree._root))

		@_container.append(@_contents)
	
	# Gets the view for the node
	#
	# @param node [Model.Node] The node to get the view for
	#
	_getView:( node ) ->
		container = $(
		   '<dl>'+
		   '</dl>'
		  )
		while node?
			element = $(
				'<dl class="undo-node">'+
				'</dl>'
			).click( node, (event) =>
				@_onClick( event.data )
			)

			dt = $('<dt>'+node._object._description+'</dt>')
			element.append(dt)

			alternatives = 0
			if node._parent? 
				alternatives = node._parent._children.length - 1

			if node is @_tree._current
				element.addClass('undo-current')
				if alternatives > 0
					@_branchIndex = node._parent._children.indexOf node
					element.append($('<dd>'+alternatives+' alternative actions</dd>'))
					@_showButtons()
				else
					@_hideButtons()
					element.append($('<dd>'+alternatives+' alternative actions</dd>'))
			else
				element.append($('<dd>'+alternatives+' alternative actions</dd>'))

			container.append(element)
			node = node._branch

		return container
	
	# Shows the buttons
	#
	_showButtons: ( ) ->
		@_leftButton.show()
		@_rightButton.show()
	
	# Hides the buttons
	#
	_hideButtons: ( ) ->
		@_leftButton.hide()
		@_rightButton.hide()

	# Is called when a node is added to the tree
	#
	# @param tree [Model.Tree] The tree the node was added to
	# @param node [Model.Node] The node that was added
	#
	_onNodeAdd:( tree, node ) ->
		if tree is @_tree
			@draw()

	# Is called when a node is removed from the tree
	#
	# @param tree [Model.Tree] The tree the node was removed from
	# @param node [Model.Node] The node that was removed
	#
	_onNodeRemove:( tree, node ) ->
		if tree is @_tree
			@draw()
	
	# Is called when a node is clicked
	#
	# @param node [Model.Node] The node that was clicked
	#
	_onClick: ( node ) ->
		nodes = @_tree.jump( node )
		for undo in nodes.reverse
			undo._object.undo()
		for redo in nodes.forward
			redo._object.redo()
		@draw()
	
	# Is called when the left button is clicked
	#
	_onClickLeftButton: ( ) ->
		length = @_tree._current._parent._children.length
		switch length
			when 1
				index = 0
			when 2
				index = !@_branchIndex + 0
			else
				index = @_branchIndex - 1
		node = @_tree._current._parent._children[index]
		@_tree.switchBranch( node )
		@draw()

	# Is called when the right button is clicked
	#
	_onClickRightButton: ( ) ->
		length = @_tree._current._parent._children.length
		switch length
			when 1
				index = 0
			when 2
				index = !@_branchIndex + 0
			else
				index = @_branchIndex + 1
		node = @_tree._current._parent._children[index]
		@_tree.switchBranch( node )
		@draw()


(exports ? this).View.Undo = View.Undo
