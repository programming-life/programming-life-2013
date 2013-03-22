class Module
  constructor: (array) ->
    @_type = array['type'];
    @_equation = array['equation'];

  # The properties
  Object.defineProperties @prototype,
      type:
      	get : -> @_type;
      	set : -> @_type;
      equation:
      	get : -> @_equation;
      	set : -> @_equation;

# Makes this available globally.
(exports ? this).Module = Module