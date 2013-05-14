# Mixin for classes that allow dynamic properties
#
DynamicProperties =

	# Defines Properties from param
	#
	# @param params [Object] properties to define
	#
	_defineProps: ( params, event ) ->
	
		@_dynamicProperties = []
		
		for key, value of params
			value = parseFloat( value ) if _( value ).isString() and !isNaN( value )
			
			# The function to create a property out of param
			#
			# @param key [String] the property name
			#
			( ( key ) => 
			
				# This defines the private value.
				Object.defineProperty( @ , "_#{key}",
					value: value
					configurable: false
					enumerable: false
					writable: true
				)

				# This defines the public functions to change
				# those values.
				Object.defineProperty( @ , key,
				
					set: ( param ) ->
						Model.EventManager.trigger( event , @, [ "_#{key}", @["_#{key}"], param ] )
						@_do( "_#{key}", param )
						
					get: ->
						return @["_#{key}"]
						
					enumerable: true
					configurable: false
				)
				
				@_dynamicProperties.push key
				
			) key
		
	# @todo replace this with events and undo tree?
	_do: ( key, param ) ->
		@[ key ] = param

( exports ? this ).Mixin.DynamicProperties = DynamicProperties