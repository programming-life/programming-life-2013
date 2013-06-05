# The TimeMachine allows for registering, undoing and redoing actions
#
# @see {Model.UndoTree} for the storage datastructure
# @see {Model.Action} for the action datastructure
#
# @mixin
#
class Mixin.Catcher

	@ClassMethods:		
		catchable: ( fns ) ->
			for name, fn of fns
				@::[ name ] = ( ) ->
					try
						fn.apply( @, arguments )
					catch e
						@_catcher.apply( @, [ @, e ] )

	@InstanceMethods: {}

		







