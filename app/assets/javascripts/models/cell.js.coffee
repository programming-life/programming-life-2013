# This is the model of a cell. It holds modules and substrates and is capable
# of simulating the modules for a timespan. A cell comes with one default 
# module which is the Cell Growth.
#
class Model.Cell extends Helper.Mixable

	@include Mixin.DynamicProperties
	@include Mixin.EventBindings

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
		@_tree = new Model.UndoTree()
		console.log(@_tree)
		
		Object.defineProperty( @, '_tree',
			value: new Model.UndoTree()
			configurable: false
			enumerable: false
			writable: true
		)
		
		Object.defineProperty( @, '_modules',
			value: []
			configurable: false
			enumerable: false
			writable: true
		)
		
		Object.defineProperty( @, '_metabolites',
			value: {}
			configurable: false
			enumerable: false
			writable: true
		)

		Object.defineProperty( @, 'module',
			
			# @property [Date] the creation date
			get : -> 
				return _( @_modules ).find( ( module ) -> module.constructor.name is "CellGrowth" )
			
			configurable: false
			enumerable: false
		)
		
		Object.defineProperty( @, 'url',
			
			# @property [String] the url for this model
			get : -> 
				data = Model.Cell.extractId( @id )
				return "/cells/#{ data.id }.json" if data.origin is "server"
				return '/cells.json'
			
			configurable: false
			enumerable: false
		)

		@_allowBindings()
		@_defineProps(  
			_( paramscell ).defaults( {
				id: _.uniqueId "client:#{this.constructor.name}:"
				creation: Date.now()
			} ),
			'cell.set.property'
		)

		
		Object.seal @
		
		Model.EventManager.trigger( 'cell.creation', @, [ @creation, @id ] )
		@_bind( 'cell.add.module', @, @_addToTree )
		@_bind( 'cell.add.metabolite', @, @_addToTree )
		
		@add new Model.CellGrowth( params, start )
		
	# Extracts id data from id
	#
	# @param id [Object,Number,String] id containing id data
	# @return [Object] extracted id data
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
			name = _( module.name.split( '#' ) ).first()
			if !@_metabolites[ name ]? 
				@_metabolites[ name ] = { }
				@_metabolites[ name ][ Model.Metabolite.Inside ] = undefined
				@_metabolites[ name ][ Model.Metabolite.Ouside ] = undefined

			func1 = (name, placement, module) =>
				@_metabolites[ name ][ placement ] = module
			func2 = (name, placement) =>
				delete @_metabolites[ name ][ placement ]

			todo = _( func1 ).bind(@, name, placement, module)
			undo = _( func2 ).bind(@, name, placement)
			action = new Model.Action(@, todo, undo, "Added "+name+" with amount " +amount)
	
			action.do()
			Model.EventManager.trigger( 'cell.add.metabolite', @, [ action, module, name, module.amount, module.placement is Model.Metabolite.Inside, module.type is Model.Metabolite.Product ] )
	
		else
			todo = _( (module) => @_modules.push module).bind(@, module)
			undo = _( (module) => @_modules = _( @_modules ).without module).bind(@, module)
			action = new Model.Action(@, todo, undo, "Added "+module.name)
			action.do()

			Model.EventManager.trigger( 'cell.add.module', @, [ action, module ] )
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
		if !@_metabolites[ name ]? 
			@_metabolites[ name ] = { }
			@_metabolites[ name ][ Model.Metabolite.Inside ] = undefined
			@_metabolites[ name ][ Model.Metabolite.Ouside ] = undefined

		placement = if inside_cell then Model.Metabolite.Inside else Model.Metabolite.Outside
		
		if @_metabolites[ name ][ placement ]? 
			func = (name, value, placement) =>
				@_metabolites[ name ][ placement ].amount = value

			oldValue = @_metabolites[ name ]
			todo = _( func ).bind(@, name, amount, placement)
			undo = _( func ).bind(@, name, oldValue, placement)
			action = new Model.Action(@, todo, undo, "Added "+name)
		else
			type = if is_product then Model.Metabolite.Product else Model.Metabolite.Substrate
			
			met = new Model.Metabolite({ supply: supply}, amount, name, placement, type)

			func1 = (name, placement, met) =>
				@_metabolites[ name ][ placement ] = met
			func2 = (name, placement) =>
				delete @_metabolites[ name ][ placement ]

			todo = _( func1 ).bind(@, name, placement, met)
			undo = _( func2 ).bind(@, name, placement)
			action = new Model.Action(@, todo, undo, "Added "+name+" with amount " +amount)

			Model.EventManager.trigger( 'cell.add.metabolite', @, [ action, met] )

		action.do()

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
		@_modules = _( @_modules ).without module
		Model.EventManager.trigger( 'cell.remove.module', @, [ module ] )
		return this
		
	# Removes this metabolite from cell
	#
	# @param name [String] metabolites to remove from this cell
	# @param placement [Integer] metabolite placement to remove from this cell
	# @return [self] chainable instance
	#
	removeMetabolite: ( name, placement ) ->
		delete @_metabolites[ name ][ placement ]
		Model.EventManager.trigger( 'cell.remove.metabolite', @, [ name, placement ] )
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
		return @_metabolites[ name ][ placement ] ? null
		
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
	# @param name [String] metabolite to check
	# @return [Integer] amount of metabolite
	amountOf: ( name, placement ) ->
		return @_metabolites[ name ][ placement ]?.amount
	
	# Runs this cell
	#
	# @param timespan [Integer] the time it should run for
	# @return [self] chainable instance
	#
	run : ( timespan, base_values = [] ) ->
		
		Model.EventManager.trigger( 'cell.before.run', @, [ timespan ] )
		
		substrates = { }
		variables = [ ]
		values = [ ]
						
		# We would like to get all the variables in all the equations, so
		# that's what we are going to do. Then we can insert the value indices
		# into the equations.
		modules = _( @_metabolites ).chain()
			.map( ( ms ) -> _( ms ).values() )
			.flatten()
			.filter( ( ms ) -> ms instanceof Model.Metabolite )
			.concat( @_modules )
			.value()

		for module in modules
			for metabolite, value of module.starts
				name = module[ metabolite ]
				index = _( variables ).indexOf( name ) 
				if ( index is -1 )
					variables.push name
					values.push value
				else
					values[ index ] += value
	
		# If we got a pre set of values, we can use that
		if base_values.length is values.length
			
			values = base_values
			append = on
			
		else if base_values.length > 0
		
			Model.EventManager.trigger( 'notification', @, 
				[ 
					'cell', 'run', 'cell:basevalues',
					'Compounds have been added or removed since the last run, so I can not continue the calculation.',
					[
						values,
						base_values
					]
				] 
			)
			append = off
	
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
					
		# The step function for this module
		#
		# @param t [Integer] the current time
		# @param v [Array] the current value array
		# @return [Array] the delta values	
		#
		step = ( t, v ) =>
		
			results = [ ]
			variables = [ ]
			
			# All dt are 0, so that when a variable was NOT processed, the
			# value remains the same
			for variable, index of mapping
				results[ index ] = 0
								
			# Get those substrates named
			mapped = map v
			
			# Calculate the mu for this timestep
			mu = @module.mu( mapped )
			
			Model.EventManager.trigger( 'cell.before.step', @, [ t, v, mu, mapped ] )
			
			# Run all the equations
			for module in modules
				module_results = module.step( t, mapped, mu )
				for variable, result of module_results
					results[ mapping[ variable ] ] += result
				
			Model.EventManager.trigger( 'cell.after.step', @, [ t, v, mu, mapped, results ] )
				
			return results
				
		# Run the ODE from 0...timespan with starting values and step function
		sol = numeric.dopri( 0, timespan, values, step )
		
		Model.EventManager.trigger( 'cell.after.run', @, [ timespan, sol, mapping ] )
		
		# Return the system results
		return { results: sol, map: mapping, append: append }
	
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
		
	# Tries to save a module
	#
	save : ( ) ->
		
		save_data = @serialize( false )
		
		# map data to server accepted data
		cell_data =
			cell:
				id: save_data.id unless @isLocal()
				name: 'My Test Cell'	
			
		# Define the modules set function, so we can resuse it
		update_modules = () =>
		
			for module in @_modules
				module.save @id
				
			for name, packet of @_metabolites
				for placement, object of packet
					if object? and object isnt null
						object.save @id
			
					
		# This is the create
		if @isLocal()
			$.post( @url, cell_data )
				.done( ( data ) => 
					
					# Lets save those results first
					@id = data.id
					
					# And now we need to store those module
					update_modules()
				)
				
				.fail( ( data ) => 
					Model.EventManager.trigger( 
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
		
		# This is the update
		else
			$.ajax( @url, { data: cell_data, type: 'PUT' } )
				.done( ( data ) => 
				
					# And now we need to store those module
					update_modules()
				)
				
				.fail( ( data ) => 
				
					Model.EventManager.trigger( 
						'notification', @, 
						[ 
							'cell', 'save', 'cell.save',
							"I am trying to update the cell #{ @id } but an error occured: #{ data }",
							[ 
								'update', 
								data, 
								module_instance_data 
							] 
						] 
					)	
				)
	
		subsequent_calls = []
		
		
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
		
		$.get( cell.url, { all: true } )
			.done( ( data ) =>
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
					
				for module_id in data.modules
					Model.Module.load( module_id, result )
					
				callback.apply( @, [ result ] ) if callback?
			)
	
	_addToTree: ( source, action, module) ->
		if source is this
			node = @_tree.add action
			module._tree.setRoot node
		
		

# Makes this available globally.
(exports ? this).Model.Cell = Model.Cell
