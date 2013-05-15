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
			for key, value of mixin when key not in Helper.Mixable.ModuleKeyWords
				@[ key ] = value
			
			mixin.extended?.apply( @ )
		this
		
	# Includes mixins to a class by adding the properties to the Prototype
	#
	# @param  instancemixins [Object*] the mixins to add
	#
	@include: ( instancemixins... ) ->
		for mixin in instancemixins
			for key, value of mixin when key not in Helper.Mixable.ModuleKeyWords
				# Assign properties to the prototype
				@::[ key ] = value

			mixin.included?.apply( @ )
		this
		
	# Concerns automagically include and extend a class
	#
	# @param  concerns [Object*] the mixins to add
	#
	@concern: ( concerns... ) ->
	
		for concern in concerns
			@include concern.InstanceMethods
			@extend concern.ClassMethods
			
		this
		
( exports ? this ).Helper.Mixable = Helper.Mixable
