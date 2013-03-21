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
		@_modules.splice( @_modules.indexOf( module ), 1 ) #TODO: update to use underscore without
		@
		
	# Checks if this cell has a module
	has: ( module ) ->
		@_modules.indexOf( module ) #TODO: ? check module type instead of object ref
	
	# Step runs this cell
	step : ( dt ) ->
		# TODO: Foreach module calculate the values of all the substances
	
	# Runs this cell
	run : ( dt, t ) ->
		# TODO: for t time run dt steps 
		# TODO: where to output
	
	# The properties
	Object.defineProperties @prototype,
		creation: get : -> @_creation;

# Makes this available globally. Use require later, but this will work for now.
(exports ? this).Cell = Cell