# View for undo functionality
#
class View.Undo extends Helper.Mixable
	
	@concern Mixin.TimeMachine
	@concern Mixin.EventBindings

	# Creates a new instance of this view
	#
	# @param container [Object] The DOM node to contain this view
	# @param tree [Model.UndoTree] The UndoTree to visualize
	#
	constructor: ( @_container, @_tree ) ->
		@_allowEventBindings()

	# Clears this view
	#
	clear: ( ) ->
		@_contents?.remove()
	
	# Redraws this view
	#
	redraw: ( ) ->
		@draw()
	
	resize: ( ) ->
		@draw()

	# Draws this view
	#
	# @param container [Object] The DOM node to contain this view
	#
	draw: ( @_container = @_container ) ->
		@clear()

		# Create the popover
		@_contents = $('<div class="undo"></div>')

		# Create the popover header
		@_header = $('<h2></h2>')
		@_contents.append(@_header)

		@_header.append("Action history")

		# Create the popover body
		@_body = $('<dl class="undo-list"></dl>')
		@_contents.append(@_body)

		# Create body content and append to body
		@_populateBody()

		# Create the popover footer
		@_footer = $('<div class="modal-footer"></div>')
		@_contents.append(@_footer)		

		@_container.append(@_contents)

	# Populates the body of the list with the items
	#
	_populateBody: ( ) ->
		console.log(@_tree)
		node = @_tree._root
		while node?
			console.log(node._object._description)
			alternatives = 0
			if node._parent? 
				alternatives = node._parent._children.length
			element = $(
				'<dt>'+node._object._description+'</dt>'+
				'<dl>'+alternatives+' alternative actions</dl>'
			)
			@_body.append(element)
			node = node._current


(exports ? this).View.Undo = View.Undo
