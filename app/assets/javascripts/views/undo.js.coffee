# View for undo functionality
#
class View.Undo extends Helper.Mixable
	
	@concern Mixin.TimeMachine
	@concern Mixin.EventBindings

	# Creates a new instance of this view
	#
	# @param tree [Model.UndoTree] The UndoTree to visualize
	#
	constructor: ( @_tree ) ->
		@_allowEventBindings()

		@_bind("tree.add.node", @, @_onNodeAdd)
		@_bind("tree.remove.node", @, @_onNodeRemove)
		@_bind("tree.select.node", @, @_onNodeSelect)

		@_rows = {}

	# Clears this view
	#
	clear: ( ) ->
		@_contents?.remove?()

	# Removes this view
	#
	kill: ( ) ->
		@_elem?.remove?()

	# Draws this view
	#
	# @return [jQuery] the drawn element
	#
	draw: ( ) ->
		@kill()

		@_elem = $('<div class="pane-content undo-view"></div>')		
		@_drawContents(@_elem)
		
		return @_elem

	# Draws the actual undo tree into container
	#
	# @param container [jQuery] the container in which to draw the contents
	#
	_drawContents: ( container = @_elem ) ->
		@clear()

		@_contents = $('<div class="undo-contents"></div>')

		header = $('<div class="pane-header navbar"><div class="navbar-inner"><span class="brand">History</span></div></div>')
		@_contents.append(header)

		body = $('<div class="undo-body"></div>')
		@_list = $('<div class="undo-list"></div>')
		@_list.append(@_getTreeView(@_tree._root))

		body.append(@_list)
		@_contents.append(body)

		@_footer = $('<div class="pane-footer navbar"><div class="navbar-inner"></div></div>')
		leftBranchButton = $('<div class="branch-button pull-left"><i class="icon-chevron-left"></i></div>')
		rightBranchButton = $('<div class="branch-button pull-right"><i class="icon-chevron-right"></i></div>')

		leftBranchButton.click(@_branchLeft)
		rightBranchButton.click(@_branchRight)
		
		@_footer.find('.navbar-inner').append(leftBranchButton)
		@_footer.find('.navbar-inner').append(rightBranchButton)
		@_contents.append(@_footer)
		container.append(@_contents)

		@_selectNode(@_tree._current)
	
	# Gets the view for the node
	#
	# @param node [Model.Node] The node to get the view for
	#
	_getTreeView: ( node ) ->
		contents = [@_getNodeView(node)]

		child = node._branch
		if child?
			return contents.concat(@_getTreeView(child))

		return contents

	# Returns a jQuery element that represents the given node. Will also
	# push this element into an object for future reference.
	#
	# @param node [Model.Node] the node to draw
	# @return [jQuery] the drawn jQuery element
	#
	_getNodeView: ( node ) ->
		row = $('<div class="undo-row"></div>')

		dl = $('<dl class="undo-node"></dl>')
		dl.append('<dt>' + node._object._description + '</dt>')

		alternatives = (node._parent?._children.length ? 1) - 1
		dl.append('<dd>' + alternatives + ' alternative actions</dd>')

		row.append(dl)

		((node) =>
			row.click( node, ( event ) =>
				@_trigger('tree.select.node', @_tree, [ event.data ])
			)
		) node
		
		@_rows[node.id] = row

		return row
	
	# Shows the buttons
	#
	_showButtons: ( ) ->
		@_footer.addClass('active-buttons')
	
	# Hides the buttons
	#
	_hideButtons: ( ) ->
		@_footer?.removeClass('active-buttons')

	# Is called when a node is added to the tree
	#
	# @param tree [Model.Tree] The tree the node was added to
	# @param node [Model.Node] The node that was added
	#
	_onNodeAdd: ( tree, node ) ->
		if tree is @_tree
			if @_list.scrollTop() == @_list[0].scrollHeight - @_list.height()
				doScroll = true

			if node._parent?._children.length - 1 > 0
				@_drawContents()
			else
				@_list.append(@_getNodeView(node))
				@_selectNode(@_tree._current)

			if doScroll
				@_scrollToBottom()

	# Is called when a node is removed from the tree
	#
	# @param tree [Model.Tree] The tree the node was removed from
	# @param node [Model.Node] The node that was removed
	#
	_onNodeRemove: ( tree, node ) ->
		if tree is @_tree
			@_list.append(@_getNodeView(node))
			@_selectNode(@_tree._current)
	
	# Is called when a node is selected
	#
	# @param tree [Model.Tree] The tree in which the node was selected
	# @param node [Model.Node] The node that was selected
	#
	_onNodeSelect: ( tree, node ) ->
		if tree is @_tree
			Model.EventManager.trigger( 'paper.lock', @_paper )

			nodes = @_tree.jump( node )
			for undo in nodes.reverse
				undo._object.undo()
			for redo in nodes.forward
				redo._object.redo()

			Model.EventManager.trigger( 'paper.unlock', @_paper )

			@_selectNode(node)

	# Mark a node in the list as selected
	#
	# @param node [Model.Node] the node to mark
	#
	_selectNode: ( node ) ->
		row = @_rows[node.id]

		@_elem.find('.undo-row').removeClass('selected')
		row.addClass('selected')

		alternatives = (node._parent?._children.length ? 1) - 1
		if alternatives > 0
			@_branchIndex = node._parent._children.indexOf node
			@_showButtons()
		else
			@_hideButtons()

	# Scroll the undo list to the bottom
	#
	# @param animate [Boolean] wether or not to animate the scroll
	#
	_scrollToBottom: ( animate = true ) ->
		if animate
			_.defer( =>
				@_list.animate(
					scrollTop: @_list[0].scrollHeight - @_list.height()
				, 500)
			)
		else
			@_list.scrollTop = @_list[0].scrollHeight - @_list.height()

	# Move one branch to the left
	#
	_branchLeft: ( ) =>
		@_branch(-1)

	# Move one branch to the right
	#
	_branchRight: ( ) =>
		@_branch(1)

	# Move one branch to either direction
	#
	# @param direction [int] the direction (-1 or 1) in which to move
	#
	_branch: ( direction ) ->
		length = @_tree._current._parent?._children?.length
		return unless length?
		
		switch length
			when 1
				index = 0
			when 2
				index = !@_branchIndex + 0
			else
				index = (@_branchIndex + direction + length) % length
		node = @_tree._current._parent._children[index]
		old = @_tree.switchBranch( node )
		old._object.undo()
		node._object.redo()
		@_drawContents()

	# Sets the tree of the view
	#
	# @param tree [Model.UndoTree] The tree to view
	#
	setTree: ( tree ) ->
		@_tree = tree
		@_drawContents()

(exports ? this).View.Undo = View.Undo
