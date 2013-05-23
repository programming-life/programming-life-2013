# Mixin for classes that allow dynamic properties
#
# @mixin
#
Mixin.DynamicProperties =

	ClassMethods: {}
	
	InstanceMethods:
	
		# Defines properties from param with accessors and a private value
		#
		# @param params [Object] properties to define
		# @param event [String] the event name to push
		#
		_propertiesFromParams: ( params, event ) ->
		
			@_dynamicProperties = []
			
			setter = ( key, value ) => 
				@["_#{key}"] = value
			
			for key, value of params
				value = parseFloat( value ) if _( value ).isString() and !isNaN( value )
				
				# The function to create a property out of param
				#
				# @param key [String] the property name
				#
				( ( key ) => 
				
					@_nonEnumerableValue( "_#{key}", value )

					# This defines the public functions to change
					# those values.
					Object.defineProperty( @ , key,
					
						set: ( param ) ->
						
							todo = _( setter ).bind( @, key, param )
							undo = _( setter ).bind( @, key, @[ "#{key}" ] )
							
							action = new Model.Action( 
								@, todo, undo, 
								"Change #{key} from #{ @[ "#{key}" ] } to #{param}" 
							)
							action.do()
							
							if event?
								func = @_trigger ? Model.EventManager.trigger
								func( event, @, [ action ] )
							
						get: ->
							return @["_#{key}"]
							
						enumerable: true
						configurable: false
					)
					
					@_dynamicProperties.push key
					
				) key
			return this
				
		# Defines a non enurable property with a value
		#
		# @param params key [String] key to define for
		# @param params value [any] value of the property
		#
		_nonEnumerableValue: ( key, value ) ->
			
			Object.defineProperty( @ , key,
				value: value
				configurable: false
				enumerable: false
				writable: true
			)
			return this
			
		# Defines Properties from param
		#
		# @param params key [String] key to define for
		# @param params value [any] value of the property
		#
		_nonEnumerableGetter: ( key, getter ) ->

			Object.defineProperty( @ , key,
				get: getter
				configurable: false
				enumerable: false
			)
			return this