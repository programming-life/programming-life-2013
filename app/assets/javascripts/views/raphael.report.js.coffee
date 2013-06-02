# Class to generate the cell in the report
#
class View.Report extends View.RaphaelBase

	# Constructor for this view
	# 	
	constructor: ( container = "#paper", @_target = container ) ->
		super( Raphael( $(container)[0], 900, 567 ) )
		
		Object.defineProperty( @, 'paper'
			get: () -> return @_paper 
		)
		
		@_paper.setViewBox(-750, -500, 1500, 1000)
		
		$( window ).on( 'resize', => _( @resize() ).debounce( 100 ) )
		@resize()
		
	# Resizes the cell to the target size
	#
	resize: ( ) =>	
		width = $( @_target ).width()
		height = $( @_target ).height() 
		
		edge = Math.min( width / 1.5, height)
		@paper.setSize( edge * 1.5 , edge )
		@_trigger( 'paper.resize', @paper )	
		