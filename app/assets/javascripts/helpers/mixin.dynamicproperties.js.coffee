# Mixin for classes that allow dynamic properties
#
# @mixin
#
Mixin.DynamicProperties =

	ClassMethods: {}		
	
	InstanceMethods:

		# Defines setters from an object of properties mapped to function calls
		#
		# @param setters [Object] the object of setters
		#
		setter: ( setters ) ->
			for key, setter of setters
				@_defineProperty(key)
				@_setters[key] = setter

		# Defines getters from an object of properties mapped to function calls
		#
		# @param getters [Object] the object of getters
		#
		getter: ( getters ) ->
			for key, getter of getters
				@_defineProperty(key)
				@_getters[key] = getter

		# Defines object properties from an object of properties
		#
		# @param properties [Object] the object of properties
		#
		property: ( properties ) ->
			for key, property of properties
				Object.defineProperty(@, key, property)

		# Defines default setters and getters for key
		#
		# @param key [String] the key for which to add setters and getters
		#
		_defineProperty: ( key ) ->
			unless @_setters?
				@_setters = {}

			unless @_getters?
				@_getters = {}			

			unless @_setters[key]? and @_getters[key]?
				try
					Object.defineProperty(@, key, 
						set: ( value ) => 
							return @_setters[key].apply( @, [ value ] )

						get: ( ) =>
							return @_getters[key].apply( @ )								
					)

					return true
				catch e # Just return false
			return false	

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
				value = parseFloat( value ) if _( value ).isString() and not isNaN(parseFloat(value)) and isFinite(value)
				
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
							
							return if ( @[ "#{key}" ] is param )
							
							todo = _( setter ).bind( @, key, param )
							undo = _( setter ).bind( @, key, @[ "#{key}" ] )
							
							action = new Model.Action( 
								@, todo, undo, 
								"Change #{key} from #{ @[ "#{key}" ] } to #{param}" 
							)
							action.do()
							
							if event?
								func = @_trigger ? Model.EventManager.trigger
								func( event, @, [ action, key, param ] )
							
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
		# @param key [String] key to define for
		# @param value [any] value of the property
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
		# @param key [String] key to define for
		# @param value [any] value of the property
		#
		_nonEnumerableGetter: ( key, getter ) ->

			Object.defineProperty( @ , key,
				get: getter
				configurable: false
				enumerable: false
			)
			return this