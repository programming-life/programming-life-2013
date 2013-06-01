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
		action = @_createAction( "Created cell" )
		@tree.setRoot( new Model.Node(action, null) )
		
		@_defineProperties( paramscell )
		
		@_trigger( 'cell.creation', @, [ @creation, @id ] )
		@_bind( 'cell.property.changed', @, @onPropertySet )
		@add new Model.CellGrowth( params, start ), false
		
	# Defines All the properties
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
				name: null
			} ),
			'cell.property.changed'
		)
		
		Object.seal @ 
		return this
		
	# Defines the value properties
	#
	# @return [self] chainable self
	#
	_defineValues: () ->
	
		@_nonEnumerableValue( '_modules', [] )
		@_nonEnumerableValue( '_metabolites', [] )
		
		return this
		
	# Defines the getters
	#
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
	add: ( module, undoable = true ) ->
	
		# Transparent adding of metabolites
		if module instanceof Model.Metabolite
			@addMetaboliteModule( module, undoable )
			return this
		
		action = 
			@_createAction( "Added a #{module.constructor.name}:#{module.name}")
				.set( 
					_( @_addModule ).bind( @, module ),
					_( @_removeModule ).bind( @, module )
				)
				.do()
		
		@addUndoableEvent( action ) if undoable
		return this
		
	# Actually adds the module to the cell
	#
	# @param module [Model.Module] module to add to the cell
	# @return [self] chainable instance
	#
	_addModule: ( module ) ->
		params = [ module ]

		@_trigger( 'cell.module.add', @, params )
		@_modules.push module
		@_trigger( 'cell.module.added', @, params )
		return this
		
		
	# Actually adds the metabolite to the cell
	# 
	# @param metabolite [Model.Metabolite] metabolite to add
	# @return [self] chainable self
	#
	addMetaboliteModule: ( metabolite, undoable = true ) ->
	
		if @hasMetabolite metabolite.name
			@getMetabolite( metabolite.name ).amount = metabolite.amount
			return this
		
		name = _( metabolite.name.split( '#' ) ).first()
		action = 
			@_createAction( "Added #{metabolite.constructor.name}: #{name} init=#{metabolite.amount} dt=#{metabolite.supply}" )
				.set( 
					_( @_addMetabolite ).bind( @, metabolite ),
					_( @_removeMetabolite ).bind( @, metabolite )
				)
				.do()
		
		@addUndoableEvent( action ) if undoable
		
		return this
		

	# Actually adds the metabolite to the cell
	#
	# @param metabolite [Model.Metabolie] Metabolie to add to the cell
	# @return [self] chainable instance
	#
	_addMetabolite: ( metabolite ) -> 
		params = [ 
				metabolite, 
				metabolite.name, 
				metabolite.amount, 
				metabolite.placement is Model.Metabolite.Inside, 
				metabolite.type is Model.Metabolite.Product 
			] 

		@_trigger( 'cell.metabolite.add', @, params )
		@_metabolites.push metabolite 
		@_trigger( 'cell.metabolite.added', @, params )
		
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
		metabolite = new Model.Metabolite( { supply: supply }, amount, name, placement, type )
		
		if @hasMetabolite metabolite.name
			@getMetabolite( metabolite.name ).amount = amount
			return this
			
		@addMetaboliteModule metabolite

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
	remove: ( module, undoable = true ) ->

		# Transparent adding of metabolites
		if module instanceof Model.Metabolite
			@removeMetabolite module.name, undoable
			return this
			
		action = 
			@_createAction( "Removed #{module.name}" )
				.set( 
					_( @_removeModule ).bind( @, module ),
					_( @_addModule ).bind( @, module )
				)
				.do()
	
		@addUndoableEvent action if undoable
		
		return this
	
	# Actually removes the module from the cell
	#
	# @param module [Model.Module] module to remove
	# @return [self] the chainable self
	#
	_removeModule: ( module ) ->
		params = [ module ]

		@_trigger( 'cell.module.remove', @, params )
		@_modules = _( @_modules ).without module
		@_trigger( 'cell.module.removed', @, params )
		return this
		
	# Removes this metabolite from cell
	#
	# @param name [String] metabolites to remove from this cell
	# @return [self] chainable instance
	#
	removeMetabolite: ( name, undoable = true ) ->
		
		return this unless @hasMetabolite name
		module = @getMetabolite name 
		
		action = 
			@_createAction( "Removed metabolite #{module.name}" )
				.set( 
					_( @_removeMetabolite ).bind( @, module ),
					_( @_addMetabolite ).bind( @, module )
				)
				.do()
		
		@addUndoableEvent action if undoable
		return this
	
	# Actually removes the metabolite from the cell
	#
	# @param name [String] the name of the metabolite
	# @param placement [Integer] the placement of the metabolite
	# @return [self] chainable instance
	#
	_removeMetabolite: ( module ) -> 
		return this unless module?

		params = [ module ]

		@_trigger( 'cell.metabolite.remove', @, params )
		@_metabolites = _( @_metabolites ).without module
		@_trigger( 'cell.metabolite.removed', @, params )
		return this
		
	# Removes this substrate from cell (alias for removeMetabolite)
	#
	# @param name [String] substrate to remove from this cell
	# @param placement [Integer] substrate placement to remove from this cell
	# @return [self] chainable instance
	#
	removeSubstrate: ( name ) ->
		return @removeMetabolite name
		
	# Removes this product from cell (alias for removeProduct)
	#
	# @param name [String] product to remove from this cell
	# @param placement [Integer] product placement to remove from this cell
	# @return [self] chainable instance
	#
	removeProduct: ( name ) ->
		return @removeMetabolite name
		
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
	# @return [Boolean] true if contains
	#
	hasMetabolite: ( name ) ->
		return _( @_metabolites ).some( ( metabolite ) -> metabolite.name is name )
		
	# Checks if this cell has this substrate (alias for hasMetabolite)
	# 
	# @param name [String] the name of the substrate
	# @return [Boolean] true if contains
	#
	hasSubstrate: ( name ) ->
		return @hasMetabolite name
		
	# Checks if this cell has this product (alias for hasMetabolite)
	# 
	# @param name [String] the name of the product
	# @return [Boolean] true if contains
	#
	hasProduct: ( name ) ->
		return @hasMetabolite name 
		
	# Gets a metabolite
	# 
	# @param name [String] the name of the metabolite
	# @return [Model.Metabolite] the metabolite
	#
	getMetabolite: ( name ) ->
		return _( @_metabolites ).find( ( metabolite ) -> metabolite.name is name ) ? undefined
		
	# Gets a substrate (alias for getMetabolite)
	# 
	# @param name [String] the name of the substrate
	# @return [Model.Metabolite] the substrate
	#
	getSubstrate: ( name ) ->
		return @getMetabolite name
		
	# Gets a product (alias for getMetabolite)
	# 
	# @param name [String] the name of the product
	# @return [Model.Metabolite] the product
	#
	getProduct: ( name ) ->
		return @getMetabolite name
	
	# Returns the amount of metabolite in this cell
	#
	# @param name [String] metabolite to check
	# @return [Integer] amount of metabolite
	#
	amountOf: ( name ) ->
		return @getMetabolite( name )?.amount
		
	# Returns the number of modules of this type
	#
	numberOf: ( module_type ) ->
		return _( @_getModules() ).where( ( module ) -> module instanceof module_type ).length
	
	# Get compound names
	# 
	# @return [Array<String>] all the compound names
	#
	getCompoundNames: () ->
		return _( @_modules ).map( ( m ) -> m.name )
	
	# Get Metabolite Names
	#
	# @return [Array<String>] all the metabolite names
	#
	getMetaboliteNames: () ->
		return _( @_metabolites ).map( ( m ) -> m.name )

	# Gets all the modules that are steppable
	# 
	# @return [Array<Model.Module>] modules
	#
	_getModules: () ->
		return _( @_metabolites ).concat @_modules
			
	# Gets all the modules that are steppable, and their compounds
	# 
	# @return [Array] {Model.Module modules}, variables, values
	#
	_getModulesAndCompounds: ( exclude = [] ) ->
	
		modules = _( @_getModules() ).difference exclude
		values = []
		variables = []
		
		for module in modules
			for metabolite, value of module.starts
				names = module[ metabolite ]
				names = [ names ] unless _( names ).isArray()
				for name in names
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
			@_notificate( @, @, 
				'cell.run.basevalues'
				'The number of compounds has changed. Restarting the calculations.',
				[ 
					values,
					base_values
				],
				Model.Cell.Notification.Info
			)
			return [ values, off ]
			
		return [ values, on ]
		
	# Runs this cell
	#
	# @param from [Integer] the time it should run from
	# @param to [Integer] the time it should run to
	# @param base_values [Array] the base values to try
	# @return [self] chainable instance
	#
	run : ( from, to, base_values = [], callback, token, stepsize = 1e-9, iterations = 4000 ) ->
		
		@_trigger( 'cell.before.run', @, [ to - from ] )
								
		exclude = []
		while not ( finished ? off )
		
			# We would like to get all the variables in all the equations, so
			# that's what we are going to do. Then we can insert the value indices
			# into the equations.
			[ modules, variables, values ] = @_getModulesAndCompounds( exclude )
			
			# Create the mapping from variable to value index
			mapping = { }
			for i, variable of variables
				mapping[variable] = parseInt i
			
			# Check modules
			finished = on
			for module in modules when module.metadata.tests? and module.metadata.tests.compounds?
				if !module.test( mapping, module.metadata.tests.compounds )
					exclude.push module
					finished = off
			
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
		[ values, continuation ] = @_tryUsingBaseValues( base_values, values )
		unless continuation
			from = 0
			to =  to - from
		
		promise = numeric.asyncdopri( 0, to - from, values, @_step( modules, mapping, map ), stepsize, iterations, undefined, token )
		promise = promise.then( ( ret ) =>
		
			@_trigger( 'cell.after.run', @, [ to - from, ret, mapping ] )
			
			result =
				results: ret
				map: mapping
				from: from + ret.x[0]
				to: from + ret.x[ret.x.length - 1 ]
				
			callback?( result )
			return result
		)
		
		# Return the system results
		return promise
		
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
		for module in @_getModules()
			modules.push module.serialize( false )
		
		result = { 
			parameters: parameters
			type: type
			modules: modules
		}
		
		return JSON.stringify( result ) if to_string
		return result
		
	# Save modules
	# 
	# @return [jQuery.Promise] the promiseses deffered 
	#
	_save_modules: () =>
		
		promiseses = []
		for module in @_getModules()
			promiseses.push module.save @id
		
		return $.when( promiseses... )
		
	# Tries to save a module
	#
	# @return [JQuery.Promise] promise
	#
	save: ( ) ->
	
		@_notificate( @, @, 
			'cell.save',
			"Saving this cell...",
			[],
			Model.Cell.Notification.Info
		)	
			
		if @isLocal()
			promise = @_create()
		else 
			promise = @_update()
		
		promise.done( ( data ) => 
			@_notificate( @, @, 
				'cell.save',
				"Successfully saved this cell",
				[]
				Model.Cell.Notification.Success
			)	
		)
		
		return promise
		
	# Gets the data to save for this cell
	#
	# @return [Object] the data
	#
	_getData: () ->
	
		save_data = @serialize( false )
		modules = []
		for module in save_data.modules
			extracted_id = Model.Module.extractId( module.id )
			modules.push extracted_id.id if extracted_id.origin is 'server'
		
		result = {
			cell:
				name: @name ? 'Cell [' + @creation + ']'
			modules: modules
				
		}
		
		result.cell.id = save_data.id unless @isLocal()
		return result
		
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
				@_notificate( @, @, 
					'cell.save',
					"I am trying to save the cell #{ @id } but an error occured: #{ data.status } - #{ data.statusText }",
					[ 
						'create', 
						data, 
						cell_data 
					],
					Model.Cell.Notification.Error
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
			
				@_notificate( @ , @, 'cell.save',
					"I am trying to update the cell #{ @id } but an error occured: #{ data.status } - #{ data.statusText }",
					[ 
							'update', 
							data, 
							cell_data  
					],
					Model.Cell.Notification.Error
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
	
		result = undefined
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
					result.remove module, false
				
				callback.apply( @, [ result ] ) if callback?
				result._notificate( @, result,
					'cell.load',
					'Loading cell...',
					[ 'load' ],
					Model.Cell.Notification.Info
				);
				
				promiseses = []
				for module_id in data.modules
					promiseses.push Model.Module.load( 
						module_id, 
						result, 
						( module ) => result.add module, false 
					)
				
				return $.when( promiseses... )
				
			# Fail
			, ( data ) => 
			
				if not result?
					result = cell
					for module in result._modules
						result.remove module, false
					
				callback.apply( @, [ result ] ) if callback?
				result._notificate( @, result, 
					'cell.load',
					"I am trying to load the cell #{ cell_id } but an error occured: #{ data.status } - #{ data.statusText }",
					[ 
						'load', 
						data, 
						cell_id 
					],
					Model.Cell.Notification.Error
				)	
			)
			
		promise.done( ( data ) => 
		
			result._notificate( @, result, 
				'cell.load',
				"Successfully loaded the cell #{ result.name }",
				[ 'load' ],
				Model.Cell.Notification.Success
			)	
		)

		return promise
		
	@loadList: ( callback ) ->
	
		cell = new Model.Cell()
		promise = $.get( cell.url, {} )
		
		return promise
		
