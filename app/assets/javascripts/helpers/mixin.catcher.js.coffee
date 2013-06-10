# The TimeMachine allows for registering, undoing and redoing actions
#
# @see {Model.UndoTree} for the storage datastructure
# @see {Model.Action} for the action datastructure
#
# @mixin
#
Mixin.Catcher =

	ClassMethods:		
		catchable: ( fns ) ->
			for name, fn of fns
				@::[ name ] = ( ) ->
					try
						return fn.apply( @, arguments )
					catch e
						@_catcher.apply( @, [ @, e ] )
						return undefined

	InstanceMethods: {}