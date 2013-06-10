# The controller for the Graphs view
#
class Controller.Settings extends Controller.Base
	
	# Creates a new instance of settings controller
	#
	constructor: ( id ) ->

		@options = @_loadOptions()
		super new View.SettingsModal @meta_options
		@view.onClose( @, @_saveOptions )
		
	# Load the options
	#
	_loadOptions: () ->
		@meta_options =
			simulate:
				iterations: 
					type: 'number'
					min: 0
					max: 100
					step: 1
					value: 4
				iteration_length: 
					type: 'number'
					min: 1
					max: 25
					step: 1
					value: 20
			ode:
				tolerance:
					type: 'number'
					min: 1e-18
					max: 1
					step: 1e-18
					value: 1e-9
				iterations:
					type: 'number'
					min: 100
					max: 10000
					step: 100
					value: 4000
				dt:
					type: 'number'
					min: 1e-9
					max: 1
					step: 1e-9
					value: 0.01
				interpolate:
					type: 'boolean'
					active: 'interpolation on'
					inactive: 'interpolation off'
					value: off
					
		results = {}
		for section, options of @meta_options
			results[ section ] = {}
			for option, meta of options
				cached = locache.get( "options.#{section}.#{option}" )
				meta.value = if cached? then cached else meta.value
				results[ section ][ option ] = meta.value
				
		return results
				
	# Save options
	#
	_saveOptions: ( modal ) ->
		return if modal isnt @view
		for input in modal.getInput()
			input = $( input )
			value = input.val()
			section = input.data( 'section' )
			key = input.data( 'key' )
			switch input.attr( 'type' )
				when 'number'
					if isNaN( value ) or not value.length
						input.val( input.attr( 'value' ) )
						continue
					value = +value
				when 'checkbox'
					value = input.is(':checked')
			@options[ section ][ key ] = value
			locache.async.set( "options.#{section}.#{key}", value )
		
		@_callback( @options ) if @_callback?
		
	# Show the modal
	#
	show: ( @_callback ) ->
		@view.show()
		
		
	