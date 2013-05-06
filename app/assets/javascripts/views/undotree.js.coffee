# View for UndoTree
#
class View.Tree
	
	# Creates a new UndoTree view
	# 
	# @param tree [Model.UndoTree] The tree to view
	# @param paper [Object] Raphael paper
	#
	constructor: ( tree, paper ) ->
		@_tree = tree
		@_paper = paper

		@_visible = on

		@_view = new View.Node( @_tree._root, @_paper )
		
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
		@_x = x
		@_y = y
		@_scale = scale

		padding = 15 * scale
		
		@_contents?.remove()

		@_contents = @_paper.set()

		# Draw stuff
		@_view.draw(x, y , scale)

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
				@_box.insertBefore(@_contents)

		# Draw shadow around module view
		@_shadow?.remove()
		@_shadow = @_box?.glow
			width: 35
			opacity: .125
		@_shadow?.scale(.8, .8)

(exports ? this).View.Tree = View.Tree
