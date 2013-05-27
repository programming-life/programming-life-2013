# Class to generate the cell in the report
#
class View.Report extends View.RaphaelBase

	# Constructor for this view
	# 
	# @param cell_id [Integer] the cell id
	# 	
	constructor: (cell_id, container = "#paper" ) ->
		container = $(container)[0]
		super( Raphael(container,750,500))

		cell = new Model.Cell()
		@_views.push new View.Cell( @_paper, @, cell, '#graphs', off)
		@_draw()
		@load( cell_id )


	# Draws the cell
	#
	_draw: () ->
		for view in @_views
			switch view.constructor.name
				when "Cell"
					view.draw(375, 250, 100)
				else
					view.draw()

	# Loads the cell, then serializes the SVG
	#
	# @param cell_id [Integer] the cell id
	#
	load: ( cell_id ) ->
		@_views[0].load( cell_id )
			.done ( () -> 
				# Enable the pdf generation button
				$('#create-pdf')[0].removeAttribute('disabled')

				# Serialize the SVG and set it as hidden value in the form
				cell_svg = (new XMLSerializer).serializeToString($('#paper').children('svg')[0])
				$('#report_data').attr("value", cell_svg)

				# Start the simulation
				document.mvc._views[0].startSimulation(25, 10, 1)
			)