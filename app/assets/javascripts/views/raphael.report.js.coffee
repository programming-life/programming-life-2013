# Class to generate the cell in the report
#
class View.Report extends View.RaphaelBase

	# Constructor for this view
	# 	
	constructor: ( container = "#paper", @_target = container ) ->
		super( Raphael( $(container)[0], 900, 567 ) )

		@paper.setViewBox(-750, -500, 1500, 1000)
		
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
		
	# Gets the progress bar
	#
	# @return [jQuery.Elem] the progress bar
	#
	getProgressBar: () ->
		return $( '#progress' )
		
	# Sets the progress bar
	#
	# @param value [Float] range 0..1 percentage filled
	# @return [self] chainable self
	#
	setProgressBar: ( value ) ->
		@getProgressBar()
			.find( '.bar' )
			.css( 'width', "#{value * 100}%" )
		return this
		
	# Hides the progress bar
	#
	# @return [self] chainable self
	#
	hideProgressBar: ( ) ->
		@getProgressBar().css( 'opacity', 0 )
		return this
		
	# Shows the progress bar
	#
	# @return [self] chainable self
	#
	showProgressBar: () ->
		@getProgressBar().css( 'visibility', 'visible' )
		@getProgressBar().css( 'opacity', 1 )
		return this