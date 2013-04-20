# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Main
	dt: 0.1
	_history: []
	_future: []

	constructor: ( ) ->
	
	# Undoes the last move. Shorthand for @_popHistory()
	#
	undo: ( ) ->
		@_popHistory()

	# Redoes the last move. Shorthand for @_popFuture()
	#
	redo: ( ) ->
		@_popFuture()

	# Pushes a move onto the history stack
	#
	# @param [String] type, the type of move. For now, 'modify' is implemented.
	# @param [Module] module, the module that has done the move.
	#
	pushHistory: ( type, module ) ->
		@_history.push([type, module])

	# Pops the last move of the history stack and calls popHistory on the right module.
	#
	_popHistory: ( ) ->
		if @_history.length > 0
			[type, module] = @_history.pop()
			switch type
				when 'modify' then module.popHistory()

	# Pushes a move onto the Future stack
	#
	# @param [String] type, the type of move. For now, 'modify' is implemented.
	# @param [Module] module, the module that has done the move.
	#
	pushFuture: ( type, module ) ->
		@_future.push([type, module])

	# Pops the last move of the future stack and calls popFuture on the right module.
	#
	_popFuture: ( ) ->
		if @_future.length > 0
			[type, module] = @_future.pop()
			switch type
				when 'modify' then module.popFuture()

$(document).ready ->
	(exports ? window).Main = new Main
		
	
