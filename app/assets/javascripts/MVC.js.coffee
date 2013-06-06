(exports ? this).Model = {}
(exports ? this).Controller = {}
(exports ? this).View = {}
(exports ? this).Helper = {}
(exports ? this).Mixin = {}
(exports ? this).GIGABASE_VERSION = 
	major: 1
	minor: 5
	revision: 0
	full: '1.5.0'

document.mvc = null

# Cache settings
locache.cachePrefix += '.gigabase.'
locache.cleanup()

(exports ? this).RouteTo = ( controller, args... ) ->

	# Updating the localstorage/serverstorage
	#
	updating = off
	update = () ->
		return if updating
	
		if document.mvc? and document.mvc.onUpdate?
			console.info 'Online! Updating controller start'
			promise = document.mvc.onUpdate()
			promise.always( () => 
				updating = off
				console.info 'Updating controller end'
			)
		else
			updating = on
	
	# Upgrading the appstorage
	#
	upgrading = off
	upgrade = () ->
		return if upgrading
		if document.mvc? and document.mvc.onUpgrade?
			console.info 'Online! Upgrade ready!'
			document.mvc.onUpgrade()
			upgrading = on
	
	# Window events
	#
	$( window )
		.on( 'beforeunload', () ->
			if document.mvc? and document.mvc.beforeUnload?
				console.info 'Before unloading!'
				message = document.mvc.beforeUnload()
				return message if message?
			return undefined
		)
		.on( 'unload', () ->
			if document.mvc? and document.mvc.onUnload?
				console.info 'Unload!'
				document.mvc.onUnload()
		)
		.on( 'online', update )
		
	# Application cache events
	#
	$( window.applicationCache )
		.on( 'updateready', upgrade )
	
	# Route
	$( document ).ready( () ->	
		document.mvc = new controller( args... )
		update() if window.navigator.onLine
		upgrade() if window.applicationCache.status is window.applicationCache.UPDATEREADY
	)
	return document.mvc
