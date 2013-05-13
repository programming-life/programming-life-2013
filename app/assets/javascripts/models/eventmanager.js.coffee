# This is the event manager to bind events
#
class Model.EventManager
	
	# Gets the singleton instance
	#
	# @return [Model.EventManager] singleton instance
	#
	@getSingleton : () ->
		( 
			() -> 
				singleton = singleton ? new EventManager()
				return singleton
		)()
		
	# Creates a new Event Manager
	#
	constructor : () ->
		@_events = {}
		
		Object.defineProperty( @, 'events',			
			# @property [Array<String>] The events available 
			get: ->
				return _.keys @_events
		)
		
		Object.seal @
		
	# Triggers an event
	#
	# @param event [String] event name
	# @param caller [Object] who triggered the event ( passed as argument )
	# @param args [Array<any>] arguments to pass
	# @return [self] chaining self
	#
	trigger : ( event, caller, args ) ->
		
		if @_events[ event ]?
			trigger = ( element, index, list ) ->
				element[ 1 ].apply( element[ 0 ], _( [ caller ] ).concat args )
			_( @_events[ event ] ).each trigger
			
		return this
		
	# Binds an event (alias for bind)
	#
	# @param event [String] event name
	# @param context [Object] who binds on the event ( passed as this )
	# @param func [Function] the event
	# @return [self] chaining self
	#
	on : ( event, context, func ) ->
		return @bind event, context, func
		
	# Unbinds an event (alias for unbind)
	#
	# @param event [String] event name
	# @param context [Context] context
	# @param func [Function] the event
	# @return [self] chaining self
	#
	off : ( event, context, func ) ->
		return @unbind event, context, func
		
	# Binds an event
	#
	# @param event [String] event name
	# @param context [Context] context
	# @param func [Function] the event
	# @return [self] chaining self
	#
	bind : ( event, context, func ) ->
		unless @_events[ event ]?
			@_events[ event ] = []
		@_events[ event ].push [ context, func ]
		return this
		
	# Unbinds an event
	#
	# @param event [String] event name
	# @param func [Function] the event
	# @param context [Context] will serve as this
	# @return [self] chaining self
	#
	unbind : ( event, context, func ) ->
		if @_events[ event ]?
			for binding in @_events[ event ] when binding[ 0 ] is context and binding[ 1 ] is func
				@_events[ event ] = _( @_events[ event ] ).without binding
		return this
	
	# Bindings for an event
	#
	# @param event [String] event name
	# @return [Array<Function>] the bindings
	#
	bindings : ( event ) ->
		if ( event? )
			return @_events[ event ] ? []
		return @_events
	

(exports ? this).Model.EventManager = Model.EventManager.getSingleton()
