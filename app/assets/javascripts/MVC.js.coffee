(exports ? this).Model = {}
(exports ? this).Controller = {}
(exports ? this).View = {}
(exports ? this).Helper = {}
(exports ? this).Mixin = {}
(exports ? this).GIGBASE_VERSION = '1.5.0'

document.mvc = null

# Cache settings
locache.cachePrefix += '.gigabase.'
locache.cleanup()

(exports ? this).RouteTo = ( controller, args... ) ->

	updating = off

	# Create a function that will ask the server for
	# updates to the article list
	update = () ->
	
		# Don't ping the server again if we're in the
		# process of updating
		return if updating
	
		if document.mvc? and document.mvc.update?
			promise = document.mvc.update()
			promise.always( () => updating = off )
			console.log 'update'
		else
			updating = on
	
	# window events
	$(window)
		.on( 'beforeunload', () ->
			if document.mvc? and document.mvc.beforeUnload?
				message = document.mvc.beforeUnload()
				return message if message?
			return undefined
		)
		.on( 'unload', () ->
			if document.mvc? and document.mvc.onUnload?
				document.mvc.onUnload()
		)
		.on( 'online', update 
		)
	
	# Route
	$( document ).ready( () ->	
		document.mvc = new controller( args... )
		
		update() if window.navigator.onLine
	)
	return document.mvc
