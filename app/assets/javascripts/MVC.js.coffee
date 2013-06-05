(exports ? this).Model = {}
(exports ? this).Controller = {}
(exports ? this).View = {}
(exports ? this).Helper = {}
(exports ? this).Mixin = {}
(exports ? this).GIGBASE_VERSION = '1.5.0'

document.mvc = null

locache.cachePrefix += '.gigabase.'
locache.cleanup()

# Unload events
$(window).on('beforeunload', () ->
	if document.mvc? and document.mvc.beforeUnload?
		message = document.mvc.beforeUnload()
		return message if message?
	return undefined
).on( 'unload', () ->
	if document.mvc? and document.mvc.onUnload?
		document.mvc.onUnload()
)