# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class MainClass
	dt: 0.1

	constructor: ( ) ->
		@cell = new Cell



$(document).ready ->
	(exports ? window).Main = new MainClass
		
	
