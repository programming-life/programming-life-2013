# View for UndoTree
#
class View.Tree extends View.Base
	
	# Creates a new UndoTree view
	# 
	# @param paper [Object] Raphael paper
	# @param tree [Model.UndoTree] The tree to view
	#
	constructor: ( paper, tree ) ->
		super( paper )
		@_tree = tree

		@_visible = on

		@_view = new View.Node( @_tree._root, @_paper, null )
		
		Object.defineProperty( @, 'visible',
			# @property [Function] the step function
			get: ->
				return @_visible
		)
	
	# Draws the view and thus the model
	#
	# @param x [Integer] The x position
	# @param y [Integer] The y position
	# @param scale [Integer] The scale
	#
	draw: ( x, y, scale ) ->
		console.log("Drawing undotree")
		if @_view._x and @_view._y
			@_x = @_view._x
			@_y = @_view._y
		else
			@_x = x
			@_y = y
		@_scale = scale

		padding = 15 * scale
		
		@_contents?.remove()

		@_contents = @_paper.set()

		# Draw stuff
		@_view.draw(@_x, @_y , @_scale)

		@_contents.push @_view._contents...

		# Draw a box around all contents
		@_box?.remove()
		if @_contents?.length > 0
			rect = @_contents.getBBox()
			if rect
				@_box = @_paper.rect(rect.x - padding, rect.y - padding, rect.width + 2 * padding, rect.height + 2 * padding)
				@_box.node.setAttribute('class', 'module-box')
				@_box.attr
					r: 10 * scale
				@_box.toBack()
				@_contents.push( @_box )

		# Draw shadow around module view
		@_shadow?.remove()
		@_shadow = @_box?.glow
			width: 35
			opacity: .125
		@_shadow?.scale(.8, .8)

(exports ? this).View.Tree = View.Tree
