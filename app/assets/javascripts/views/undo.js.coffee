# View for undo functionality
#
class View.Undo extends Helper.Mixable
	
	@concern Mixin.TimeMachine
	@concern Mixin.EventBindings

	# Creates a new instance of this view
	#
	# @param tree [Model.UndoTree] The UndoTree to visualize
	#
	constructor: ( @timemachine ) ->
		@_allowEventBindings()
		@_createBindings()

		@_rows = {}

	# Creates bindings for the view
	#
	_createBindings: ( ) ->
		@_bind("tree.node.added", @, @_onNodeAdd)
		@_bind("tree.root.set", @, @_onRootSet )
		@_bind("controller.undo.branch.finished", @, @_onBranch )

	# Clears this view
	#
	# @return [self] For chaining
	#
	clear: ( ) ->
		@_contents?.remove()
		return @

	# Removes this view
	#
	# @return [self] For chaining
	#
	kill: ( ) ->
		@_elem?.remove()
		return @

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
		@_list.append(@_getTreeView(@timemachine.root))

		body.append(@_list)
		@_contents.append(body)

		@_footer = $('<div class="pane-footer navbar"><div class="navbar-inner"></div></div>')
		leftBranchButton = $('<div class="branch-button pull-left"><i class="icon-chevron-left"></i></div>')
		rightBranchButton = $('<div class="branch-button pull-right"><i class="icon-chevron-right"></i></div>')

		leftBranchButton.click( () =>
			@_trigger "view.undo.branch", @, [ -1 ]
		)
		rightBranchButton.click( () =>
			@_trigger "view.undo.branch", @, [ 1 ]
		)
		
		@_footer.find('.navbar-inner').append(leftBranchButton)
		@_footer.find('.navbar-inner').append(rightBranchButton)
		@_contents.append(@_footer)
		container.append(@_contents)

		@selectNode(@timemachine.current)
	
	# Gets the view for the node
	#
	# @param node [Model.Node] The node to get the view for
	#
	_getTreeView: ( node ) ->
		contents = [@_getNodeView(node)]

		child = node.branch
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
		unless node.object instanceof Model.Action
			return
		row = $('<div class="undo-row"></div>')

		dl = $('<dl class="undo-node"></dl>')
		dl.append('<dt>' + node.object._description + '</dt>')

		alternatives = (node.parent?.children.length ? 1) - 1
		dl.append('<dd>' + alternatives + ' alternative actions</dd>')

		row.append(dl)

		((node) =>
			row.click( node, ( event ) =>
				@_trigger('view.undo.node.selected', @, [ event.data ])
			)
		) node
		
		@_rows[node.id] = row

		return row
	
	# Shows the buttons
	#
	_showButtons: ( ) ->
		@_footer?.addClass('active-buttons')
	
	# Hides the buttons
	#
	_hideButtons: ( ) ->
		@_footer?.removeClass('active-buttons')

	# Is called when a node is added to the tree
	#
	# @param tree [Model.Tree] The tree the node was added to
	# @param node [Model.Node] The node that was added
	# @return [Boolean] True is the tree was our timachine, false otherwise
	#
	_onNodeAdd: ( tree, node ) ->
		if tree is @timemachine
			if @_list.scrollTop() == @_list[0].scrollHeight - @_list.height()
				doScroll = true

			if node.parent?.children.length <= 1
				@_list.append(@_getNodeView(node))
				@selectNode(@timemachine.current)
			else
				@_drawContents()

			if doScroll
				@_scrollToBottom()

		return tree is @timemachine

	# Gets called when the root of the tree is set
	#
	# @param tree [Model.Tree] The tree
	# @param node [Model.Node] The new root
	# @return [Boolean] True is the tree was our timachine, false otherwise
	#
	_onRootSet: ( tree, node ) ->
		if tree is @timemachine
			@_drawContents()
		return tree is @timemachine
	
	# Gets called when branching occurs
	#
	_onBranch: ( ) ->
		if @_elem?
			@_drawContents()

	# Mark a node in the list as selected
	#
	# @param node [Model.Node] the node to mark
	#
	selectNode: ( node ) ->
		row = @_rows[node.id]

		@_elem.find('.undo-row').removeClass('selected')
		if row?
			row.addClass('selected')

		alternatives = (node.parent?.children.length ? 1) - 1
		if alternatives > 0
			@_branchIndex = node.parent.children.indexOf node
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

	# Sets the tree of the view
	#
	# @param tree [Model.UndoTree] The tree to view
	#
	setTree: ( tree ) ->
		@timemachine = tree
		@_drawContents()
	
	# Sets the view of node to active
	#
	# @param node [Model.Node] The node
	#
	setActive: ( node ) ->
		view = @_rows[node.id]
		if view?
			view.addClass("active")
			view.removeClass("inactive")

	# Sets the view of node to inactive
	#
	# @param node [Model.Node] The node
	#
	setInactive: ( node ) ->
		view = @_rows[node.id]
		if view?
			view.removeClass("active")
			view.addClass("inactive")
