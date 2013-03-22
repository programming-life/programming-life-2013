# Describes the module with its type (DNA, transporter, etc),
# and the right equation.
#
# @example Creating a new module
#	Module dna = new Module('DNA', 'x+y-z*k')
class Module
	# Constructs a new module, accepting a type and its equation

	# @param [String] type the type of module
	# @param [String] the equation of this type of module
	constructor: (type, equation) ->
    	@_type = type
    	@_equation = equation

  	# Getters and setters
  	Object.defineProperties @prototype,
      	type:
      		get : -> @_type
      		set : (value) -> @_type = value
      	equation:
      		get : -> @_equation
      		set : (value) -> @_equation = value

# Makes this globally available
(exports ? this).Module = Module