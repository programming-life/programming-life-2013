# The TimeMachine allows for registering, undoing and redoing actions
#
# @see {Model.UndoTree} for the storage datastructure
# @see {Model.Action} for the action datastructure
#
# @mixin
#
Mixin.TimeMachine = 
	
	ClassMethods: {}
	
	InstanceMethods: 
	
		# Intializes the timemachine
		#
		_allowTimeMachine: () ->
			@_tree = new Model.UndoTree() unless @_tree?
			return this
			
		# Adds an undoable event to the tree
		#
		# @params action [Model.Action] action that is undoable
		# @return [Model.Node] the tree node returned
		#
		addUndoableEvent: ( action ) ->
			return @_tree.add action
		
		# Adds an undoable event to the subtree
		#
		# @params action [Model.Action] action that is undoable
		# @params sub [TimeMachine] sub that has timemachine
		# @return [Model.Node] the tree node returned
		#	
		addUndoableEventToSub: ( action, sub ) ->
			tree_node = @addUndoableEvent action
			sub?._tree?.setRoot tree_node
			return tree_node
			
		# Undoes the last action
		#
		undo: () ->
			action = @_tree.undo()
			action.undo() if action?
			return this
			
		# Redoes the last action
		#
		redo: () ->
			action = @_tree.redo()
			action.redo() if action?
			return this
			
		# Creates an empty action
		#
		# @param description [String] the description for the action
		# @param context [Context] defaults to this
		# @returns [Model.Action] the action
		#
		_createAction: ( description, context = @ ) ->
			return new Model.Action( context, undefined, undefined, description )