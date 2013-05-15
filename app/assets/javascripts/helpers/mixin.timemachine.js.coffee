#
#
TimeMachine = 
	
	ClassMethods: {}
	
	InstanceMethods: 
	
		#
		#
		_allowTimeMachine: () ->
			@_tree = new Model.UndoTree() unless @_tree?
			return this
			
		# Adds an undoable event to the tree
		#
		# @params action [Model.Action] action that is undoable
		# @return [Model.Node]
		#
		addUndoableEvent: ( action ) ->
			return @_tree.add action
		
		# Adds an undoable event to the subtree
		#
		# @params action [Model.Action] action that is undoable
		# @params sub [TimeMachine] sub that has timemachine
		# @return [Model.Node]
		#	
		addUndoableEventToSub: ( action, sub ) ->
			tree_node = @addUndoableEvent action
			sub?._tree?.setRoot tree_node
			return tree_node
			
		#
		#
		undo: () ->
			action = @_tree.undo()
			action.undo() if action?
			return this
			
		#
		#
		redo: () ->
			action = @_tree.redo()
			action.redo() if action?
			return this
			
		#
		#
		_createAction: ( description, context = @ ) ->
			return new Model.Action( context, undefined, undefined, description )
			
( exports ? this ).Mixin.TimeMachine = TimeMachine