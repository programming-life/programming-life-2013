###
# Module #

Describes the module with its type (DNA, transporter, etc),
and the right equation.
###

class Module
	###
	Constructs a new module, accepting a type and its equation
	@in: type:String, equation:String
	###
	constructor: (type, equation) ->
    	@_type = type
    	@_equation = equation

  	### 
  	Property gets/sets
  	###
  	Object.defineProperties @prototype,
      	type:
      		get : -> @_type
      		set : -> @_type
      	equation:
      		get : -> @_equation
      		set : -> @_equation
### 
Makes this available globally.
###
(exports ? this).Module = Module