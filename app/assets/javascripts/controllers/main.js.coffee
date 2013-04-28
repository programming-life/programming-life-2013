# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# The controller for the Main action and view
#
class Main

	dt: 0.1
	_tree: new UndoTree()

	# Creates a new instance of Main
	constructor: ( ) ->
	
	# Undoes the last move.
	undo: ( ) ->
		object = [type, module]
		@_tree.add( object )

	# Redoes the last move.
	redo: ( ) ->
		[type, module] = @_tree.redo()
		switch type
			when 'modify' then module.redo()

	# Adds a move to the undotree
	#
	# @param [String] type, the type of move. For now, 'modify' is implemented.
	# @param [Module] module, the module that has done the move.
	#
	addMove: ( type, module ) ->
		object = [type, module]
		@_tree.add( object )


$(document).ready ->
	(exports ? window).Main = new Main
		
	
