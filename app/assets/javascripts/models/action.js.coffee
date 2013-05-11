# A model for the action object used for (un)doing
#
class Model.Action
	
	# Creates a new action object
	#
	# @param context [Object] The context to execute the action is
	# @param do [Function] The function to execute in the context on (re)do
	# @param undo [Function] The function to execute in the context on undo
	# @param description [String] A description of the action
	constructor: ( context, todo, undo, description = "Action") ->
		@_context = context
		@_todo = todo
		@_undo = undo
		@_description = description
	
	# Apply the do function on context
	# 
	do: ( ) ->
		@_todo.apply( @_context)
	
	# Apply the undo function on context
	#
	undo: ( ) ->
		@_undo.apply( @_context)
	
	# Wrapper for do for convenience
	# 
	redo: ( ) ->
		@do()

		
	
(exports ? this).Model.Action = Model.Action
