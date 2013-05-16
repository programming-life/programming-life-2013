# This is the model of a cell. It holds modules and substrates and is capable
# of simulating the modules for a timespan. A cell comes with one default 
# module which is the Cell Growth.
#
# @concern Mixin.DynamicProperties
# @concern Mixin.EventBindings
# @concern Mixin.TimeMachine
#
class Model.Cell extends Helper.Mixable

	@concern Mixin.DynamicProperties
	@concern Mixin.EventBindings
	@concern Mixin.TimeMachine

	# Constructor for cell
	#
	# @param params [Object] parameters for the cellgrowth module
	# @param start [Integer] the initial value of cell
	# @param paramscell [Object] parameters for the cell
	# @param start [Integer] the initial value of cell
	# @option params [String] lipid the name of lipid for mu
	# @option params [String] protein the name of protein for mu
	# @option params [String] consume the consume metabolite for mu
	# @option params [String] name the name, defaults to "cell"
	# @option paramscell [Integer] id the id
	# @option paramscell [Integer] creation the creation time
	#
	constructor: ( params = {}, start = 1, paramscell = {} ) ->
		
		@_allowEventBindings()
		@_allowTimeMachine()
		
		@_defineProperties( paramscell )
		
		@_trigger( 'cell.creation', @, [ @creation, @id ] )
		@_bind( 'cell.set.property', @, @onPropertySet )
		@add new Model.CellGrowth( params, start )
		
	# Defines All the properties
	#
	# @see {DynamicProperties} for function calls
	#
	# @return [self] chainable self
	#
	_defineProperties: ( params ) ->
				
		@_defineValues()
		@_defineGetters()
		
		@_propertiesFromParams(  
			_( params ).defaults( {
				id: _.uniqueId "client:#{this.constructor.name}:"
				creation: Date.now()
			} ),
			'cell.set.property'
		)
		
		Object.seal @ 
		return this
		
	# Defines the value properties
	#
	# @see {DynamicProperties} for function calls
	# @return [self] chainable self
	#
	_defineValues: () ->
	
		@_nonEnumerableValue( '_modules', [] )
		@_nonEnumerableValue( '_metabolites', {} )
		
		return this
		
	# Defines the getters
	#
	# @see {DynamicProperties} for function calls
	# @return [self] chainable self
	#
	_defineGetters: () ->
		
		@_nonEnumerableGetter( 'module', () -> 
				return _( @_modules ).find( ( module ) -> module.constructor.name is "CellGrowth" ) 
		)
		
		@_nonEnumerableGetter( 'url', () ->
				data = Model.Cell.extractId( @id )
				return "/cells/#{ data.id }.json" if data.origin is "server"
				return '/cells.json'
		)

		return this
		
	# Triggered when a property is set
	#
	# @param caller [any] the originating property
	# @param action [Model.Action] the action invoked
	#
	onPropertySet: ( caller, action ) =>
		if caller is @
			@addUndoableEvent( action )
		
	# Extracts id data from id
	#
	# @param id [Object,Number,String] id containing id data
	# @return [Object] extracted id data
	#
	@extractId: ( id ) ->
		return id if _( id ).isObject()
		return { id: id, origin: "server" } if _( id ).isNumber()
		return null unless _( id ).isString()
		data = id.split( ':' )
		return { id: parseInt( data[0] ), origin: "server" } if data.length is 1
		return { id: parseInt( data[2] ), origin: data[0] }
		
	# Returns true if local cell
	#
	# @return [Boolean] true if local, false if synced
	#
	isLocal : () ->
		return Model.Cell.extractId( @id ).origin isnt "server"
	
	# Add module to cell
	#
	# @param module [Model.Module] module to add to this cell
	# @return [self] chainable instance
	#
	add: ( module ) ->
	
		# Transparent adding of metabolites
		if module instanceof Model.Metabolite
			@addMetaboliteModule module
			return this
		
		action = 
			@_createAction( "Added #{module.name}")
				.set( 
					_( @_addModule ).bind( @, module ),
					_( @_removeModule ).bind( @, module )
				)
				.do()
		
		@addUndoableEventToSub( action, module )
		return this
		
	# Actually adds the module to the cell
	#
	# @param module [Model.Module] module to add to the cell
	# @return [self] chainable instance
	#
	_addModule: ( module ) ->
		@_modules.push module
		@_trigger( 'cell.add.module', @, [ module ] )
		return this
		
	# Ensures that metabolite can be accessed
	#
	# @param name [String] metabolite name
	# @return [self] chainable instance
	#
	_ensureMetaboliteAllocation: ( name ) ->
		if !@_metabolites[ name ]? 
			@_metabolites[ name ] = { }
			@_metabolites[ name ][ Model.Metabolite.Inside ] = undefined
			@_metabolites[ name ][ Model.Metabolite.Ouside ] = undefined
		return this
		
	# Actually adds the metabolite to the cell
	# 
	# @param metabolite [Model.Metabolite] metabolite to add
	# @return [self] chainable self
	#
	addMetaboliteModule: ( metabolite ) ->
	
		name = _( metabolite.name.split( '#' ) ).first()
		@_ensureMetaboliteAllocation( name )
		
		action = 
			@_createAction( "Added metabolite #{name} with amount #{metabolite.amount}" )
				.set( 
					_( @_addMetabolite ).bind( @, name, metabolite.placement, metabolite ),
					_( @_removeMetabolite ).bind( @, name, metabolite.placement )
				)
				.do()
		
		@addUndoableEventToSub( action, metabolite )
		
		return this
		

	# Actually adds the metabolite to the cell
	#
	# @param name [String] the name of the metabolite
	# @param placement [Integer] the placement of the metabolite
	# @param metabolite [Model.Metabolie] Metabolie to add to the cell
	# @return [self] chainable instance
	#
	_addMetabolite: ( name, placement, metabolite ) -> 
		@_metabolites[ name ][ placement ] = metabolite 
		@_trigger( 'cell.add.metabolite', @, 
			[ 
				metabolite, 
				name, 
				metabolite.amount, 
				metabolite.placement is Model.Metabolite.Inside, 
				metabolite.type is Model.Metabolite.Product 
			] 
		)
		return this
		
	# Add metabolite to cell
	#
	# @param name [String] name of the metabolite to add
	# @param amount [Integer] amount of metabolite to add
	# @param supply [Integer] supply of param of metabolite
	# @param inside_cell [Boolean] if true is placed inside the cell
	# @param is_product [Boolean] if true is placed right of the cell
	# @return [self] chainable instance
	#
	addMetabolite: ( name, amount, supply = 1, inside_cell = off, is_product = off ) ->
		
		placement = if inside_cell then Model.Metabolite.Inside else Model.Metabolite.Outside
		type = if is_product then Model.Metabolite.Product else Model.Metabolite.Substrate
		
		if @_metabolites[ name ]? and @_metabolites[ name ][ placement ]? 
			@_metabolites[ name ][ placement ].amount = amount
			return this
			
		@addMetaboliteModule( new Model.Metabolite( { supply: supply }, amount, name, placement, type ) )

		return this
		
	# Add metabolite substrate to cell
	#
	# @param name [String] name of the metabolite to add
	# @param amount [Integer] amount of metabolite to add
	# @param supply [Integer] supply of param of metabolite
	# @param inside_cell [Boolean] if true is placed inside the cell
	# @return [self] chainable instance
	#
	addSubstrate: ( name, amount, supply = 1, inside_cell = off ) ->
		return @addMetabolite( name, amount, supply, inside_cell, off )
		
	# Add metabolite product to cell
	#
	# @param name [String] name of the metabolite to add
	# @param amount [Integer] amount of metabolite to add
	# @param inside_cell [Boolean] if true is placed inside the cell
	# @return [self] chainable instance
	#
	addProduct: ( name, amount, inside_cell = on ) ->
		return @addMetabolite( name, amount, 0, inside_cell, on )
		
	# Remove module from cell
	#
	# @param module [Model.Module] module to remove from this cell
	# @return [self] chainable instance
	#
	remove: ( module ) ->
	
		# Transparent adding of metabolites
		if module instanceof Model.Metabolite
			name = _( module.name.split( '#' ) ).first()
			@removeMetabolite name, module.placement
			return this
			
		action = 
			@_createAction( "Removed #{module.name}" )
				.set( 
					_( @_removeModule ).bind( @, module ),
					_( @_addModule ).bind( @, module )
				)
				.do()
	
		@addUndoableEvent( action )
		
		return this
	
	# Actually removes the module from the cell
	#
	# @param module [Model.Module] module to remove
	# @return [self] the chainable self
	#
	_removeModule: ( module ) ->
		@_modules = _( @_modules ).without module
		@_trigger( 'cell.remove.module', @, [ module ] )
		return this
		
	# Removes this metabolite from cell
	#
	# @param name [String] metabolites to remove from this cell
	# @param placement [Integer] metabolite placement to remove from this cell
	# @return [self] chainable instance
	#
	removeMetabolite: ( name, placement ) ->
		
		return this unless @hasMetabolite( name, placement )
		
		module = @getMetabolite( name, placement )
		
		action = 
			@_createAction( "Removed metabolite #{module.name}" )
				.set( 
					_( @_removeMetabolite ).bind( @, name, placement ),
					_( @_addMetabolite ).bind( @, name, placement, module )
				)
				.do()
		
		@addUndoableEvent( action )
		return this
	
	# Actually removes the metabolite from the cell
	#
	# @param name [String] the name of the metabolite
	# @param placement [Integer] the placement of the metabolite
	# @param metabolite [Model.Metabolie] Metabolie to remove from the cell
	# @return [self] chainable instance
	#
	_removeMetabolite: ( name, placement ) -> 
		module = @_metabolites[ name ][ placement ]
		delete @_metabolites[ name ][ placement ]
		@_trigger( 'cell.remove.metabolite', @, [ module ] )
		return this
		
	# Removes this substrate from cell (alias for removeMetabolite)
	#
	# @param name [String] substrate to remove from this cell
	# @param placement [Integer] substrate placement to remove from this cell
	# @return [self] chainable instance
	#
	removeSubstrate: ( name, placement ) ->
		return @removeMetabolite( name, placement )
		
	# Removes this product from cell (alias for removeProduct)
	#
	# @param name [String] product to remove from this cell
	# @param placement [Integer] product placement to remove from this cell
	# @return [self] chainable instance
	#
	removeProduct: ( name, placement ) ->
		return @removeMetabolite( name, placement )
		
	# Checks if this cell has a module
	#
	# @param module [Model.Module] the module to check
	# @return [Boolean] true if the module is included
	#
	has: ( module ) ->
		return @_modules.indexOf( module ) isnt -1
		
	# Checks if this cell has this metabolite
	# 
	# @param name [String] the name of the metabolite
	# @param placement [Integer] metabolite placement
	# @return [Boolean] true if contains
	#
	hasMetabolite: ( name, placement ) ->
		return @_metabolites[ name ][ placement ]?
		
	# Checks if this cell has this substrate (alias for hasMetabolite)
	# 
	# @param name [String] the name of the substrate
	# @param placement [Integer] substrate placement
	# @return [Boolean] true if contains
	#
	hasSubstrate: ( name, placement ) ->
		return @hasMetabolite( name, placement )
		
	# Checks if this cell has this product (alias for hasMetabolite)
	# 
	# @param name [String] the name of the product
	# @param placement [Integer] product placement
	# @return [Boolean] true if contains
	#
	hasProduct: ( name, placement ) ->
		return @hasMetabolite( name, placement )
		
	# Gets a metabolite
	# 
	# @param name [String] the name of the metabolite
	# @param placement [Integer] metabolite placement
	# @return [Model.Metabolite] the metabolite
	#
	getMetabolite: ( name, placement ) ->
		return @_metabolites[ name ]?[ placement ] ? null
		
	# Gets a substrate (alias for getMetabolite)
	# 
	# @param name [String] the name of the substrate
	# @param placement [Integer] substrate placement
	# @return [Model.Metabolite] the substrate
	#
	getSubstrate: ( name, placement ) ->
		return @getMetabolite( name, placement )
		
	# Gets a product (alias for getMetabolite)
	# 
	# @param name [String] the name of the product
	# @param placement [Integer] product placement
	# @return [Model.Metabolite] the product
	#
	getProduct: ( name, placement ) ->
		return @getMetabolite( name, placement )
	
	# Returns the amount of metabolite in this cell
	#
	# @param name [String] metabolite to check
	# @return [Integer] amount of metabolite
	#
	amountOf: ( name, placement ) ->
		return @_metabolites[ name ][ placement ]?.amount

	# Gets all the modules that are steppable
	# 
	# @return [Array<Model.Module>] modules
	#
	_getModules: () ->
		return _( @_metabolites ).chain()
			.map( ( ms ) -> _( ms ).values() )
			.flatten()
			.filter( ( ms ) -> ms instanceof Model.Metabolite )
			.concat( @_modules )
			.value()
			
	# Gets all the modules that are steppable, and their compounds
	# 
	# @return [Array] {Model.Module modules}, variables, values
	#
	_getModulesAndCompounds: () ->
	
		modules = @_getModules()
		values = []
		variables = []
		for module in modules
			for metabolite, value of module.starts
				name = module[ metabolite ]
				index = _( variables ).indexOf( name ) 
				if ( index is -1 )
					variables.push name
					values.push value
				else
					values[ index ] += value
					
		return [ modules, variables, values ]
		
	# Tries using the base values as values
	#
	# @param base_values [Array<Float>] the base values to try
	# @param values [Array<Float>] the default values
	# @return [Array] values, used base values
	#
	_tryUsingBaseValues: ( base_values, values ) ->
	
		if base_values.length is values.length
			return [ base_values, on ]
			
		if base_values.length > 0
			@_trigger( 'notification', @, 
				[ 
					'cell', 'run', 'cell:basevalues',
					'Compounds have been added or removed since the last run, so I can not continue the calculation.',
					[
						values,
						base_values
					]
				] 
			)
			return [ values, off ]
			
		return [ values, on ]
		
	# Runs this cell
	#
	# @param timespan [Integer] the time it should run for
	# @param base_values [Array] the base values to try
	# @return [self] chainable instance
	#
	run : ( timespan, base_values = [] ) ->
		
		@_trigger( 'cell.before.run', @, [ timespan ] )
		
		substrates = { }
						
		# We would like to get all the variables in all the equations, so
		# that's what we are going to do. Then we can insert the value indices
		# into the equations.
		[ modules, variables, values ] = @_getModulesAndCompounds()
		[ values, continuation ] = @_tryUsingBaseValues( base_values, values )
	
		# Create the mapping from variable to value index
		mapping = { }
		for i, variable of variables
			mapping[variable] = parseInt i
			
		# The map function to map substrates
		#
		# @param values [Array] the values to map
		# @return [Object] the mapped substrates	
		#
		map = ( values ) => 
			variables = { }
			for variable, i of mapping
				variables[ variable ] = values[ i ]
			return variables

		# Run the ODE from 0...timespan with starting values and step function
		sol = numeric.dopri( 0, timespan, values, @_step( modules, mapping, map ) )
		
		@_trigger( 'cell.after.run', @, [ timespan, sol, mapping ] )
		
		# Return the system results
		return { results: sol, map: mapping, append: continuation }
		
	# The step function for the cell
	#
	# @param t [Integer] the current time
	# @param v [Array] the current value array
	# @param mapping
	# @param map
	# @return [Array] the delta values	
	#
	_step: ( modules, mapping, map ) ->
	
		return ( t, v ) =>
			results = [ ]
			variables = [ ]
			
			# All dt are 0, so that when a variable was NOT processed, the
			# value remains the same
			for variable, index of mapping
				results[ index ] = 0
				
			mapped = map v
			mu = @module.mu( mapped )
			
			@_trigger( 'cell.before.step', @, [ t, v, mu, mapped ] )
			
			# Run all the equations
			for module in modules
				module_results = module.step( t, mapped, mu )
				for variable, result of module_results
					results[ mapping[ variable ] ] += result
				
			@_trigger( 'cell.after.step', @, [ t, v, mu, mapped, results ] )
				
			return results
	
	# Serializes a cell
	# 
	# @param to_string [Boolean] Stringifies object if try, default true
	# @return [String,Object] JSON Object or String
	#
	serialize : ( to_string = on ) ->
		
		parameters = {}
		for parameter in @_dynamicProperties 
			parameters[parameter] = @[parameter]
		type = @constructor.name
		
		modules = []
		for module in @_modules
			modules.push module.serialize( false )
			
		metabolites = {}
		for name, packet of @_metabolites
			for placement, object of packet
				if object? and object isnt null
					metabolites[ object.name ] = object.serialize( false )
		
		result = { 
			parameters: parameters
			type: type
			modules: _( modules ).concat( _( metabolites ).values() )
		}
		
		return JSON.stringify( result ) if to_string
		return result
		
	# Save modules
	# 
	# @return [jQuery.Promise] the promiseses deffered 
	#
	_save_modules: () =>
		
		promiseses = []
		for module in @_modules
			promiseses.push module.save @id
			
		for name, packet of @_metabolites
			for placement, object of packet
				if object? and object isnt null
					promiseses.push object.save @id
		
		return $.when( promiseses... )
		
	# Tries to save a module
	#
	# @return [JQuery.Promise] promise
	#
	save: ( ) ->
			
		if @isLocal()
			return @_create()

		return @_update()
		
	# Gets the data to save for this cell
	#
	# @return [Object] the data
	#
	_getData: () ->
	
		save_data = @serialize( false )
		return {
			cell:
				id: save_data.id unless @isLocal()
				name: 'My Test Cell'	
		}
		
	# Creates (new) this cell
	# 
	# @return [jQuery.Promise] the promise
	#
	_create: () ->
	
		cell_data = @_getData()
		promise = $.post( @url, cell_data )
		promise = promise.then( 
			# Done
			( data ) => 			
				@id = data.id
				return @_save_modules()
			
			# Fail
			, ( data ) => 
				@_trigger( 
					'notification', @, 
					[ 
						'cell', 'save', 'cell.save',
						"I am trying to save the cell #{ @id } but an error occured: #{ data }",
						[ 
							'create', 
							data, 
							module_instance_data 
						] 
					] 
				)	
			)
		
		return promise
		
	# Updates (existing) this cell
	# 
	# @return [jQuery.Promise] the promise
	#
	_update: () ->
		
		cell_data = @_getData()
		promise = $.ajax( @url, { data: cell_data, type: 'PUT' } )
		
		promise = promise.then( 
			# Done
			( data ) =>
				return @_save_modules()
			
			,
			# Fail
			( data ) => 
			
				@_trigger( 
					'notification', @, 
					[ 
						'cell', 'save', 'cell.save',
						"I am trying to update the cell #{ @id } but an error occured: #{ data }",
						[ 
							'update', 
							data, 
							cell_data 
						] 
					] 
				)	
			)
		
		return promise

	# Deserializes a cell
	# 
	# @param serialized [Object,String] the serialized object
	# @return [Model.Cell] the cell
	#
	@deserialize : ( serialized = {} ) ->
		
		serialized = JSON.parse( serialized ) if _( serialized ).isString()
		fn = ( window || @ )["Model"]
		
		result = new fn[serialized.type]( undefined, undefined, serialized.parameters  )
		
		for module in result._modules
			result.remove module

		for module in serialized.modules
			result.add Model.Module.deserialize( module )
			
		return result
		
	# Loads a cell
	# 
	# @param cell_id [Integer] the id of the cell
	# @param callback [Function] function to call on completion
	#
	@load : ( cell_id, callback ) ->
	
		cell = new Model.Cell( undefined, undefined, { id: cell_id } )
		promise = $.get( cell.url, { all: true } )
		promise = promise.then( 
			
			# Done
			( data ) =>
				result = new Model.Cell( 
					undefined,
					undefined,
					{ 
						id: data.cell.id
						name: data.cell.name
						#creation: new Date(data.created_at).getTime()
					}
				)
				for module in result._modules
					result.remove module
				
				promiseses = []
				for module_id in data.modules
					promiseses.push Model.Module.load( module_id, result )
					
				callback.apply( @, [ result ] ) if callback?
				
				return $.when( promiseses... )
				
			# Fail
			, ( data ) => 
			
				cell._trigger( 
					'notification', cell, 
					[ 
						'cell', 'load', 'cell.load:#{cell_id}',
						"I am trying to load the cell #{ cell_id } but an error occured: #{ data }",
						[ 
							'load', 
							data, 
							cell_id 
						] 
					] 
				)	
			)

		return promise

# Makes this available globally.
(exports ? this).Model.Cell = Model.Cell
