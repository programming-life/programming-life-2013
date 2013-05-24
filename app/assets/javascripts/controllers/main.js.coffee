# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# The controller for the Main action and view
#
class Controller.Main

	# Creates a new instance of Main
	#
	# @param container [String, Object] A string with an id or a DOM node to serve as a container for the view
	#
	constructor: ( container ) ->
		@view = new View.Main container
		
	# Loads a new cell into the main view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback ) ->
		return @view.load cell_id, callback
		
	# Saves the main view cell
	#
	# @return [jQuery.Promise] the promise
	#
	save: () ->
		return @view.save()