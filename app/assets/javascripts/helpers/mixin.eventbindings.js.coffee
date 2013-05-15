# Mixin for event enabled classes
#
EventBindings =
	 
	ClassMethods: {}
		
	InstanceMethods:
	
		# Enables bindings
		#
		# @return [self] chainable self
		#
		_allowEventBindings: _( () ->
				@_bindings = {} 
				return this 
			).once()
		 
		# Unbinds all events
		#
		# @return [self] chainable self
		# 
		_unbindAll: () ->
			@_allowEventBindings()
			for event, bindings of @_bindings
				for binding in bindings
					@_unbind( event, binding[ 0 ], binding[ 1] )
			return this
			
		# Binds an event
		# 
		# @param event [String] the event to bind to
		# @param context [Context] the context to bind with
		# @param method [Function] the method to bind
		# @return [self] chainable self
		#
		_bind: ( event, context, method ) ->
			@_allowEventBindings()
			Model.EventManager.on( event, context, method )
			unless @_bindings[ event ]? 
				 @_bindings[ event ] = []
			@_bindings[ event ].push [ context, method ]
			return this
		
		# Unbinds an event
		# 
		# @param event [String] the event to unbind from
		# @param context [Context] the context to unbind for
		# @param method [Function] the method to unbind
		# @return [self] chainable self
		#
		_unbind: ( event, context, func ) ->
			@_allowEventBindings()
			Model.EventManager.off( event, context, func )
			if @_bindings[ event ]?
				for binding in @_bindings[ event ] when binding[ 0 ] is context and binding[ 1 ] is func
					@_bindings = _( @_bindings ).without binding
			return this
			
( exports ? this ).Mixin.EventBindings = EventBindings