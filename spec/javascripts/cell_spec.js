describe("Cell", function() {
	var cell;
	var module;

	beforeEach(function() {
		cell = new Model.Cell();
	});

	it("should have a creation date", function() {
		expect( cell.creation ).toBeDefined();
	});

	it("should have an undotree", function() {
		expect( cell._tree ).toBeDefined();
	});
	
	describe("the tree", function() {
		var tree;
		beforeEach( function() {
			tree = cell._tree;
		});

		it("should have only a root node", function() {
			expect( tree._root ).toBeDefined();

		});
	});

	it("should accept custom params", function() {
		cell = new Model.Cell( { name: "custom_name"} );
		expect( cell ).toBeDefined();
	});

	it("should accept a custom start time", function() {
		cell = new Model.Cell( undefined, 2 );
		expect( cell ).toBeDefined();
	})
	
	it("should be able to serialize the cell", function() {
		serialized = cell.serialize( true )
		expect( serialized ).toBeDefined();
		expect( serialized.length ).toBeGreaterThan( 2 )
	});
  
	describe("when a module has been added", function() {
		var oldLength;
		beforeEach(function() {
			module = new Model.Module()

			if (cell._tree._current._parent != null)
				oldLength = cell._tree._current._parent._children.length;
			else
				oldLength = 0

			cell.add( module );
		});

		it("should have that module", function() {
			expect( cell.has( module ) ).toBeTruthy();
		});
		
		it("should be able to remove that module", function() {
			cell.remove( module );
			expect( cell.has( module ) ).toBeFalsy();
		});

		it("should have added a node to the undotree", function() {
			console.log( cell._tree )
			expect( cell._tree._current._parent._children.length ).toBe( oldLength + 1 );
		});

	});
	
	describe("when a metabolite has been added", function() {
		var metabolite_name = 'mock';
		var metabolite_amount = 42;
		var metabolite_supply = 2;
		var placement = Model.Metabolite.Outside;
		var type = Model.Metabolite.Substrate;
		
		beforeEach(function() {
			cell.addMetabolite( metabolite_name, metabolite_amount, metabolite_supply, false, false );
		});
		
		it("should have that metabolite", function() {
			expect( cell.hasMetabolite( metabolite_name, placement ) ).toBeTruthy();
			substrate = cell.getMetabolite( metabolite_name, placement );
			expect( substrate ).toBeDefined();
			expect( substrate ).not.toBe( null );
		});
		
		it("should have the amount specified", function() {
			expect( cell.amountOf( metabolite_name, placement ) ).toBe( metabolite_amount );
			metabolite = cell.getMetabolite( metabolite_name, placement );
			expect( metabolite.amount ).toBe( metabolite_amount );
		});
		
		it("should have the supply specified", function() {
			metabolite = cell.getMetabolite( metabolite_name, placement );
			expect( metabolite.supply ).toBe( metabolite_supply );
		});
		
		it("should have the type specified", function() {
			metabolite = cell.getMetabolite( metabolite_name, placement );
			expect( metabolite.type ).toBe( type );
		});
		
		it("should have the placement specified", function() {
			metabolite = cell.getMetabolite( metabolite_name, placement );
			expect( metabolite.placement ).toBe( placement );
		});
	});
		
	describe("when an external substrate has been added", function() {
	
		var substrate_name = 'mock';
		var substrate_amount = 42;
		var substrate_supply = 2;
		var placement = Model.Metabolite.Outside;
		var type = Model.Metabolite.Substrate;
		
		beforeEach(function() {
			cell.addSubstrate( substrate_name, substrate_amount, substrate_supply, false );
		});
		
		it("should have that substrate", function() {
			expect( cell.hasSubstrate( substrate_name, placement ) ).toBeTruthy();
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate ).toBeDefined();
			expect( substrate ).not.toBe( null );
		});
		
		it("should have the amount specified", function() {
			expect( cell.amountOf( substrate_name, placement ) ).toBe( substrate_amount );
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate.amount ).toBe( substrate_amount );
		});
		
		it("should have the supply specified", function() {
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate.supply ).toBe( substrate_supply );
		});
		
		it("should have the type specified", function() {
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate.type ).toBe( type );
		});
		
		it("should have the placement specified", function() {
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate.placement ).toBe( placement );
		});

		it("should be able to remove that substrate", function() {
			cell.removeSubstrate( substrate_name, placement );
			expect( cell.hasSubstrate( substrate_name, placement ) ).toBeFalsy();
			expect( cell.getSubstrate( substrate_name, placement ) ).toBeNull();
			expect( cell.amountOf( substrate_name, placement ) ).not.toBeDefined();
		});
			
		it("should replace the substrate amount if it already exists", function () {
			substrate = cell.getSubstrate( substrate_name, placement );
			cell.addSubstrate( substrate_name, substrate_amount + 1, substrate_supply, false );
			expect( substrate ).toBe( cell.getSubstrate( substrate_name, placement ) );
			expect( cell.amountOf( substrate_name, placement ) ).toBe( substrate_amount + 1 );
			expect( substrate.amount ).toBe( substrate_amount + 1 );
		});
		
	});
	
	describe("when an internal substrate has been added", function() {
	
		var substrate_name = 'mock';
		var substrate_amount = 42;
		var substrate_supply = 2;
		var placement = Model.Metabolite.Inside;
		var type = Model.Metabolite.Substrate;
		
		beforeEach(function() {
			cell.addSubstrate( substrate_name, substrate_amount, substrate_supply, true );
		});
		
		it("should have that substrate", function() {
			expect( cell.hasSubstrate( substrate_name, placement ) ).toBeTruthy();
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate ).toBeDefined();
			expect( substrate ).not.toBe( null );
		});
		
		it("should have the amount specified", function() {
			expect( cell.amountOf( substrate_name, placement ) ).toBe( substrate_amount );
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate.amount ).toBe( substrate_amount );
		});
		
		it("should have the supply specified", function() {
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate.supply ).toBe( substrate_supply );
		});
		
		it("should have the type specified", function() {
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate.type ).toBe( type );
		});
		
		it("should have the placement specified", function() {
			substrate = cell.getSubstrate( substrate_name, placement );
			expect( substrate.placement ).toBe( placement );
		});

		it("should be able to remove that substrate", function() {
			cell.removeSubstrate( substrate_name, placement );
			expect( cell.hasSubstrate( substrate_name, placement ) ).toBeFalsy();
			expect( cell.getSubstrate( substrate_name, placement ) ).toBeNull();
			expect( cell.amountOf( substrate_name, placement ) ).not.toBeDefined();
		});
			
		it("should replace the substrate amount if it already exists", function () {
			substrate = cell.getSubstrate( substrate_name, placement );
			cell.addSubstrate( substrate_name, substrate_amount + 1, substrate_supply, true );
			expect( substrate ).toBe( cell.getSubstrate( substrate_name, placement ) );
			expect( cell.amountOf( substrate_name, placement ) ).toBe( substrate_amount + 1 );
			expect( substrate.amount ).toBe( substrate_amount + 1 );
		});

	});
		
	describe("when a metabolite is added", function() {
	
		var substrate_amount = 42;
		var substrate_supply = 2;

		it("can be an external substrate", function() {
		
			var placement = Model.Metabolite.Outside;
			var type = Model.Metabolite.Substrate;
		
			cell.addSubstrate( 'e_substrate', substrate_amount, substrate_supply, false );
			expect( cell.hasSubstrate( 'e_substrate', placement  ) ).toBeTruthy();
			substrate = cell.getSubstrate( 'e_substrate', placement );
			expect( substrate.placement ).toBe( placement );
			expect( substrate.type ).toBe( type );
		});
		
		it("can be an internal substrate", function() {
		
			var placement = Model.Metabolite.Inside;
			var type = Model.Metabolite.Substrate;
		
			cell.addSubstrate( 'i_substrate', substrate_amount, substrate_supply, true );
			expect( cell.hasSubstrate( 'i_substrate', placement  ) ).toBeTruthy();
			substrate = cell.getSubstrate( 'i_substrate', placement );
			expect( substrate.placement ).toBe( placement );
			expect( substrate.type ).toBe( type );
		});
		
		
		it("can be an internal product", function() {
		
			var placement = Model.Metabolite.Inside;
			var type = Model.Metabolite.Product;
		
			cell.addProduct( 'i_product', substrate_amount, true );
			expect( cell.hasProduct( 'i_product', placement  ) ).toBeTruthy();
			substrate = cell.getProduct( 'i_product', placement );
			expect( substrate.placement ).toBe( placement );
			expect( substrate.type ).toBe( type );
		});

		it("can be an external product", function() {
		
			var placement = Model.Metabolite.Outside;
			var type = Model.Metabolite.Product;
		
			cell.addProduct( 'e_product', substrate_amount, false );
			expect( cell.hasProduct( 'e_product', placement  ) ).toBeTruthy();
			substrate = cell.getProduct( 'e_product', placement );
			expect( substrate.placement ).toBe( placement );
			expect( substrate.type ).toBe( type );
		});
	});
	
	describe("when the cell has ran", function() {
		var run_t = 10;
		var result;
		
		beforeEach(function() {
			result = cell.run( run_t );
		});
		
		it("should have run with t runtime", function() {
			expect( result ).toBeDefined();
			expect( result.results.x ).toBeDefined();
			expect( result.results.x[ 0 ] ).toBe( 0 );
			expect( result.results.x[ result.results.x.length - 1 ] ).toBe( run_t );
			
		});
	});
	
	describe( "and Module Integration", function() {
		var cell;
		var create_transport, transport_food, food_enzyme;
		
		var enzyme = 1;
		var food = 100;

		beforeEach(function() {
			cell = new Model.Cell();
			cell.addSubstrate( 'food', food, 0, false );
			cell.addSubstrate( 'food', 0, 0, true );
				
			create_transport = new Model.Module(
				{ 
					rate: 2, 
					name : 'transp' ,
					starts : { 
						name : 0 
					}
				}, 
				function ( t, substrates ) {
					return { 'transp' : this.rate }
				}
			);

			transport_food = new Model.Module(
				{ rate: 1 },
				function ( t, compounds ) {
					transporters = compounds.transp
					food_out = compounds["food#ext"]
					transport = Math.min( transporters * this.rate, Math.max( 0, food_out ) )
					return { 
						'food#ext' : -transport, 
						'food#int' : transport 
					}
				}
			);

			food_enzyme = new Model.Module(
				{ starts: { name : enzyme }, name: 'enzyme' },
				function ( t, compounds ) {

					food_in = compounds["food#int"]
					enzyme = compounds.enzyme
					processed = Math.min( enzyme, Math.max( 0, food_in ) )
					return { 
						'food#int' : -processed 
					}
				}
			);

			cell.add( create_transport )
				.add( transport_food )
				.add( food_enzyme )
		});

		describe( "when ran for 0 seconds", function() {
			var results, result, mapping;
			
			beforeEach(function() {
				results = cell.run( 0 );
				result = results.results;
				mapping = results.map;
			});
			
			it("should have input values", function() {
				expect( result ).toBeDefined();
				expect( result.y[ result.y.length - 1 ][ mapping.enzyme ] ).toBe( enzyme );
				expect( result.y[ result.y.length - 1 ][ mapping["food#ext"] ] ).toBe( food );
				expect( result.y[ result.y.length - 1 ][ mapping["food#int"] ] ).toBe( 0 );
				expect( result.y[ result.y.length - 1 ][ mapping.transp ] ).toBe( 0 );
			});
			
		});
		
		describe( "when ran for 2 seconds", function() {
			var result, mapping;
			
			beforeEach(function() {
				results = cell.run( 2 );
				result = results.results;
				mapping = results.map;
			});
			
			it("should have kept all the enzym", function() {
				expect( result.y[ result.y.length - 1 ][ mapping.enzyme ] ).toBe( enzyme );
			});
			
			it("should have created transporters", function() {
				expect( result.y[ result.y.length - 1 ][ mapping.transp ] ).toBe( create_transport.rate * 2 );
			});
			
			it("should have transported food", function() {
				expect( result.y[ result.y.length - 1 ][ mapping["food#int"] ] ).toBeGreaterThan( 0 );
				expect( result.y[ result.y.length - 1 ][ mapping["food#ext"] ] ).toBeLessThan( food );
			});
			
			it("should have consumed food", function() {
				expect( 
					result.y[ result.y.length - 1 ][ mapping["food#int"] ] + 
					result.y[ result.y.length - 1 ][ mapping["food#ext"] ] 
				).toBeLessThan( food );
			});

			it("should summed up the rate if a second transporter uses the same substrate", function() {
				create_transport_2 = new Model.Module(
					{ 
						rate: 2, 
						name : 'transp' ,
						starts : { 
							name : 0 
						}
					}, 
					function ( t, substrates ) {
						return { 'transp' : this.rate }
					}
				);

				cell.add( create_transport_2 );

				results = cell.run( 2 );
				result = results.results;
				mapping = results.map;

				expect( result.y[ result.y.length - 1 ][ mapping.transp ] ).
					toBe( (create_transport.rate + create_transport_2.rate) * 2);
			});
			
		});
		
		xdescribe( "serialized and deserilized, should retain substrates, modules, cell", function() {
		
		});
	});
	
	
});
