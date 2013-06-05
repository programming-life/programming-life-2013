#
#
class Helper.Mixable
	
	@ModuleKeyWords : [ 'extended', 'included' ]

	# Extends a class by adding the properties of the mixins to the class
	#
	# @param classmixins [Object*] the mixins to add
	#
	@extend: ( classmixins... ) ->
	
		for mixin in classmixins
			for key, value of mixin when key not in Mixable.ModuleKeyWords
				@[ key ] = value
			
			mixin.extended?.apply( @ )
		this
		
	# Includes mixins to a class by adding the properties to the Prototype
	#
	# @param  instancemixins [Object*] the mixins to add
	#
	@include: ( instancemixins... ) ->
		for mixin in instancemixins
			for key, value of mixin when key not in Mixable.ModuleKeyWords
				# Assign properties to the prototype
				@::[ key ] = value

			mixin.included?.apply( @ )
		return this
		
	# Concerns automagically include and extend a class
	#
	# @param  concerns [Object*] the mixins to add
	#
	@concern: ( concerns... ) ->
	
		for concern in concerns
			@include concern.InstanceMethods
			@extend concern.ClassMethods
			
		return this
		
	# Extracts id plus metadata
	# 
	# @param id [String,Integer,Object] the id
	# @return [Object] the id plus metadata
	#
	@extractId: ( id ) ->
		return id if _( id ).isObject()
		return { id: id, origin: "server" } if _( id ).isNumber()
		return null unless _( id ).isString()
		data = id.split( ':' )
		return { id: parseInt( data[0] ), origin: "server" } if data.length is 1
		return { id: parseInt( data[2] ), origin: data[0] }
		
	# Returns true if this is a local instance
	# 
	# @return [Boolean] true if local, false if synced instance
	#
	isLocal : () ->
		console.log @id, Helper.Mixable.extractId( @id )
		return Helper.Mixable.extractId( @id ).origin isnt "server"

	# Parses a date with or without timezone offset to a javascript date
	#
	# @param data [String] the date in ISO-something format
	# @return [Date] the parsed date
	# 
	@parseDate: ( date ) ->
		matchOffset = /(Z|([+-])(\d\d):(\d\d))$/
		offset = matchOffset.exec date
		result = new Date( date.replace( 'T', 'T' ).replace( matchOffset, 'Z' ) )
		unless offset[ 1 ] is 'Z' 
			timezone = ( if offset[ 2 ] is '+' then -1 else 1 ) * ( offset[ 3 ] * 60 + Number( offset[ 3 ] ) )
			result.setMinutes( result.getMinutes() + timezone ) #- result.getTimezoneOffset() 
		return result;
