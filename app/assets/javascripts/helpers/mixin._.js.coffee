class Helper.Mixable
	
	@moduleKeywords: [ 'extended', 'included' ]

	@extend: (obj) ->
		for key, value of obj when key not in Helper.Mixable.moduleKeywords
			@[ key ] = value
			
		obj.extended?.apply( @ )
		this
 
	@include: (obj) ->
		for key, value of obj when key not in Helper.Mixable.moduleKeywords
			# Assign properties to the prototype
			@::[ key ] = value

		obj.included?.apply( @ )
		this
		
( exports ? this ).Helper.Mixable = Helper.Mixable