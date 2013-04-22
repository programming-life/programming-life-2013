# Tree with explicit undo and redo functionality
class UndoTree extends Tree

	constructor: ( root ) ->
		super(root)
	
	# 
	add: ( object ) ->
		for child in @_current._children
			@_current = child if child._object is object

		@_current = super( object, @_current)
		return @_current
	
	undo: ( ) ->
		if @_current isnt @_root
			object = @_current._object
			@_current = @_current._parent
			return object
		else
			return [null,null]
	
	redo: ( ) ->
		if @_current._branch isnt null
			@_current = @_current._branch
			object = @_current._object
			return object
		else
			return [null,null]

(exports ? this).UndoTree = UndoTree
