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

# Default modules
#
#	@example Cell
#		new Module('Cell', [S_int * Lipid * Protein] * [DNA, Lipid, Protein] * Cell)
# @example DNA
#		new Module('DNA', k_DNA * DNA * Prod * S_int * Lipid * Protein * DNA)
# @example Lipid
#		new Module('Lipid', k_L * DNA * S_int - [S_int * Lipid * Protein * Lipid])
# @example Transporter
#		new Module('Transporter', k_Tr * DNA * S_int - [S_int * Lipid * Protein * Transporter])
#	@example Proteine
#		new Module('Protein', k_p * DNA - [S_int * Lipid * Protein * Protein] - [k^p_d * Protein])
@_defaults = 
{
	cell : new Module('Cell', '(0.5 * 0.3 * 0.6) * (0.3 * 0.1 * 0.2) * 0.5')
	DNA: new Module('DNA', '0.7 * 0.3 * 0.6 * 0.5 * 0.3 * 0.6 * 0.3'),
	lipid: new Module('Lipid', '0.4 * 0.3 * 0.6 - (0.5 * 0.3 * 0.6 * 0.1)')
	transporter: new Module('Transporter', '0.3 * 0.3 * 0.6 - (0.5 * 0.3 * 0.6 * 0.6)')
	protein: new Module('Protein', '0.2 * 0.3 - (0.5 * 0.3 * 0.6 * 0.6) - (0.1 * 0.6)')
}
(exports ? this).defaults = @_defaults
