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
			unless @_tree?
			
				Object.defineProperty( @, 'tree',
					value: new Model.UndoTree()
					writable: false
					configurable: false
					enumerable: false
				)

				Object.defineProperty( @, 'timemachine',
					get: -> @tree
				)
				
			return this
			
		# Adds an undoable event to the tree
		#
		# @params action [Model.Action] action that is undoable
		# @return [Model.Node] the tree node returned
		#
		addUndoableEvent: ( action ) ->
			return @tree.add action
		
		# Undoes the last action
		#
		undo: () ->
			action = @tree.undo()
			action.undo() if action?
			return this
			
		# Redoes the last action
		#
		redo: () ->
			action = @tree.redo()
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
