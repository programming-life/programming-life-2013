# Mixin for event enabled classes
#
# @mixin
#
Mixin.EventBindings =
	 
	ClassMethods: 
	
		Notification:
			Success: 0
			Warning: 1
			Error: 2
			Info: 3
		
	InstanceMethods:
	
		# Enables bindings
		#
		# @return [self] chainable self
		#
		_allowEventBindings: () ->
			@_bindings = {} unless @_bindings?
			return this 
				 
		# Unbinds all events
		#
		# @return [self] chainable self
		# 
		_unbindAll: () ->
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
			Model.EventManager.off( event, context, func )
			if @_bindings[ event ]?
				for binding in @_bindings[ event ] when binding[ 0 ] is context and binding[ 1 ] is func
					@_bindings[ event ] = _( @_bindings[ event ] ).without binding
			return this
			
		# Triggers an event
		# 
		# @param event [String] the event to trigger for
		# @param caller [Context] the caller to trigger from
		# @param args [Array] the arguments to send
		# @return [self] chainable self
		#
		_trigger: ( event, caller, args ) ->
			Model.EventManager.trigger( event, caller, args )
			return this
			
		# Notification for a source binder event handler
		# 
		# @param context [Context] the context for the callback
		# @param source [Context] the source of the message
		# @param callback [Function] the function to run
		#
		_onNotificate: ( context, source, callback ) ->
			bound_source = source
			@_bind( 'notification', context, 
				( caller, source, args... ) -> 
					if source is undefined or source is bound_source
						callback.apply( context, [ caller, bound_source ].concat( args ) )
			)	
			
		# Notificates all listeners
		#
		# @param context [Context] the caller to trigger from
		# @param source [Context] the source of the message
		# @param identifier [any] the message identifier
		# @param message [String] the message
		# @param args [Array<any>] the additional arguments
		# @return [self] chainable self
		#
		_notificate: ( caller, source, identifier, message, args, type = Mixin.EventBindings.ClassMethods.Notification.Info ) ->
			return @_trigger( 'notification', caller, [ source, identifier, type, message, args ] )


		# Bind keys to a specific function
		#
		# @param keys [Array] A array of keys, in the form of: [charCode, alt, ctrl, shift]
		# @param element [JQuery] The DOM element to bind to
		# @param context [Object] The context of the callback
		# @param callback [Function] The function to call
		#
		_bindKeys: ( keys, element, context, callback ) ->
			console.log "Binding",element, "to",context,callback,"on",keys
			$(document).on("keyup", (event) ->
				trigger = [event.which, event.altKey, event.ctrlKey, event.shiftKey]
				if _.isEqual trigger, keys
					_.debounce( callback.apply( context ), 300 )
					event.stopPropagation()
			)
			
