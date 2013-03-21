class Cell

	# The constructor for the cell
	constructor: ( ) ->
		@_creation = Date.now()
		@_modules = []
	
	# Add module to cell
	add: ( module ) ->
		@_modules.push( module )
		@
		
	# Remove module from cell
	remove: ( module ) ->
		@_modules.splice( @_modules.indexOf( module ), 1 ) # update to use underscore without
		@
	
	# The properties
	Object.defineProperties @prototype,
		creation: get : -> @_creation;

# Makes this available globally. Use require later, but this will work for now.
(exports ? this).Cell = Cell