# The controller for the Undo view
#
class Controller.Undo extends Controller.Base

	# Creates a new instance of Undo
	#
	#
	#
	#
	constructor: ( @model, view ) ->
		super view ? new View.Undo( @model )
		@_bind "view.undo.node.selected", @, @_onNodeSelected
		@_bind "view.undo.branch", @, @_onBranch
		
	# Set the timemachine of the view
	#
	# @param timemachine [Mixin.TimeMachine] The timemachine
	#
	setTimeMachine: ( timemachine ) ->
		@view.setTree timemachine
		return this
	
	# Gets called when a node is selected in the view
	#
	# @param source [View.Undo] The undo view in which the event occurs
	# @param node [Model.Node] The node that was selected
	#
	_onNodeSelected: ( source, node ) ->
		if source is @view
			@jump node
			@focus node
	
	# Focusses a node in the view
	#
	# @param [Model.Node] The node to focus
	#
	focus: ( node = @model.current ) ->
		@view.selectNode(node)
	
	# Gets called when branching occurs
	#
	# @param direction [Integer] The direction of the branching. -1 == left, 1 == right
	#
	_onBranch: ( source, direction ) ->
		if source is @view
			@branch direction
	
	# Jump to a specific point in time
	#
	# @param node [Model.Node] The node to jump to
	#
	jump: ( node ) ->
		@_trigger "controller.undo.jump.started", @, []
		nodes = @model.jump( node )
		
		for undo in nodes.reverse
			undo.object.undo()
		for redo in nodes.forward
			redo.object.redo()

		@_trigger "controller.undo.jump.finished", @, [ nodes ]
	
	# Move one branch to either direction
	#
	# @param direction [int] the direction (-1 or 1) in which to move
	#
	branch: ( direction ) ->
		@_trigger "controller.undo.branch.started", @, []
		length = @model.current.parent.children.length
		return unless length > 1

		branchIndex = @model.current.parent.children.indexOf @model.current.parent.branch
		
		switch length
			when 2
				index = !branchIndex + 0
			else
				index = (branchIndex + direction + length) % length

		node = @model.current.parent.children[index]
		old = @model.switchBranch( node )
		old.object.undo()
		node.object.redo()

		@_trigger "controller.undo.branch.finished", @, []
	
	# Focuses the undo view on a specific timemachine
	#
	# @param timemachine [Mixin.TimeMachine] The timemachine to focus on
	#
	focusTimeMachine: ( timemachine ) ->
		nodes = []
		for otherNode in timemachine.iterator()
			node = @model.find( otherNode.object )
			nodes.push node if node?
		for node in @model.iterator()
			if node in nodes
				@view.setActive( node )
			else
				@view.setInactive( node )
	
	# Undoes the current action
	#
	undo: ( ) ->
		action = @model.undo()
		action?.undo()
		@focus()

	# Redoes the next action
	#
	redo: ( ) ->
		action = @model.redo()
		action?.redo()
		@focus()
