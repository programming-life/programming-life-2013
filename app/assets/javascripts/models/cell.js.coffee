# This is the model of a cell. It holds modules and substrates and is capable
# of simulating the modules for a timespan. A cell comes with one default 
# module which is the Cell Growth.
#
class Model.Cell

	# Constructor for cell
	#
	# @param params [Object] parameters for this cell
	# @param start [Integer] the initial value of cell
	# @option params [String] lipid the name of lipid to consume
	# @option params [String] protein the name of protein to consume
	# @option params [String] consume the consume substrate to consume
	# @option params [String] name the name, defaults to "cell"
	#
	constructor: ( params = {}, start = 1 ) ->
		
		@_modules = []
		@_substrates = {}
		
		creation = Date.now()
		module = new Model.CellGrowth(  params, start )
		
		Object.defineProperty( @, 'module',
			# @property [Model.CellGrowth] the cell growth module
			get: ->
				return module
		)
		
		Object.defineProperty( @, 'creation',
			# @property [Date] the creation date
			get : -> 
				return creation
		)
		
		Object.seal @
		
		Model.EventManager.trigger( 'cell.creation', @, [ creation ] )
		
		@add module
	
	# Add module to cell
	#
	# @param module [Model.Module] module to add to this cell
	# @return [self] chainable instance
	#
	add: ( module ) ->
		@_modules.push module
		Model.EventManager.trigger( 'cell.add.module', @, [ module ] )
		return this
		
	# Add substrate to cell
	#
	# @param substrate [String] substrate to add
	# @param amount [Integer] amount of substrate to add
	# @param inside_cell [Boolean] if true is placed inside the cell
	# @param is_product [Boolean] if true is placed right of the cell
	# @return [self] chainable instance
	#
	addSubstrate: ( substrate, amount, inside_cell = on, is_product = off ) ->
		if ( @_substrates[ substrate ]? )
			@_substrates[ substrate ].amount = amount
		else
			@_substrates[ substrate ] = new Model.Substrate( {}, amount, substrate, inside_cell, is_product )
			Model.EventManager.trigger( 'cell.add.substrate', @, [ substrate, amount, inside_cell, is_product ] )
		return this
		
	# Remove module from cell
	#
	# @param module [Model.Module] module to remove from this cell
	# @return [self] chainable instance
	#
	remove: ( module ) ->
		@_modules = _( @_modules ).without module
		Model.EventManager.trigger( 'cell.remove.module', @, [ module ] )
		return this
		
	# Removes this substrate from cell
	#
	# @param substrate [String] substrate to remove from this cell
	# @return [self] chainable instance
	#
	removeSubstrate: ( substrate ) ->
		delete @_substrates[ substrate ]
		Model.EventManager.trigger( 'cell.remove.substrate', @, [ substrate ] )
		return this
		
	# Checks if this cell has a module
	#
	# @param module [Model.Module] the module to check
	# @return [Boolean] true if the module is included
	#
	has: ( module ) ->
		return @_modules.indexOf( module ) isnt -1
		
	# Checks if this cell has this substrate
	# 
	# @param substrate [String] the name of the substrate
	# @return [Boolean] true if contains
	#
	hasSubstrate : ( substrate ) ->
		return @_substrates[ substrate ]?
		
	# Gets a substrate
	# 
	# @param substrate [String] the name of the substrate
	# @return [Model.Substrate] the substrate
	#
	getSubstrate : ( substrate ) ->
		return @_substrates[ substrate ] ? null
	
	# Returns the amount of substrate in this cell
	# @param substrate [String] substrate to check
	# @return [Integer] amount of substrate
	amountOf: ( substrate ) ->
		return @_substrates[ substrate ]?.amount
	
		
	# Runs this cell
	#
	# @param timespan [Integer] the time it should run for
	# @return [self] chainable instance
	#
	run : ( timespan ) ->
		
		Model.EventManager.trigger( 'cell.before.run', @, [ timespan ] )
		
		substrates = {}
		variables = [ ]
		values = [ ]
						
		# We would like to get all the variables in all the equations, so
		# that's what we are going to do. Then we can insert the value indices
		# into the equations.
		modules = _( @_modules ).concat( _.values( @_substrates ) )
		for module in modules
			for substrate, value of module.starts
				name = module[substrate]
				index = _(variables).indexOf( name ) 
				if ( index is -1 )
					variables.push name
					values.push value
				else
					values[index] += value
	
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
			for module in @_modules
				module_results = module.step( t, mapped, mu )
				for variable, result of module_results
					results[ mapping[ variable ] ] += result
				
			Model.EventManager.trigger( 'cell.after.step', @, [ t, v, mu, mapped, results ] )
				
			return results
				
		# Run the ODE from 0...timespan with starting values and step function
		sol = numeric.dopri( 0, timespan, values, step )
		
		Model.EventManager.trigger( 'cell.after.run', @, [ timespan, sol, mapping ] )
		
		# Return the system results
		return { results: sol, map: mapping }
	
	# Visualizes this cell
	#
	# @param duration [Integer] A duration for the simulation.
	# @param container [Object] A container for the graphs.
	# @param options [Object] the options for this visualisation
	# @option options [Integer] dt the timestep, defaults to 1
	# @option options [Object] graph the graph options
	# @option options [Object] graph.key the graph options for that key
	# @option options [Object] graphs the original graphs
	# 
	# @return [Object] Returns the graphs
	#
	visualize: ( duration, container, options = { } ) ->
		
		cell_run = @run duration
		results = cell_run.results
		mapping = cell_run.map
		
		dt = options.dt ? 1
		
		# Get the interpolation for a fixed timestep instead of the adaptive timestep
		# generated by the ODE. This should be fairly fast, since the values all 
		# already there ( ymid and f )
		interpolation = []
		for time in [ 0 .. duration ] by dt
			interpolation[ time ] = results.at time;
 
		graphs = options.graphs ? { }
		
		Model.EventManager.trigger( 'cell.before.visualize', @, [ duration, container, graphs ] )	
		
		# Draw all the substrates
		for key, value of mapping
		
			# Get the options for this graph
			graph_options = { dt : dt }
			if ( options.graph )
				graph_options = _( options.graph[ key ] ? options.graph ).extend( graph_options  ) 
		
			dataset = []
			if ( !graphs[ key ] )
				graphs[ key ] = new Graph( key, graph_options ) 
			
			# Push all the values, but round for float rounding errors
			for time in [ 0 .. duration ] by dt
				dataset.push( interpolation[ time ][ value ] ) 
				
			graphs[ key ].addData( dataset, graph_options )
				.render(container)

		Model.EventManager.trigger( 'cell.after.visualize', @, [ duration, container, graphs ] )		
		
		# Return graphs
		return graphs		

# Makes this available globally.
(exports ? this).Model.Cell = Model.Cell
