describe("Cell", function() {
	var cell;
	var module;

	beforeEach(function() {
		cell = new Cell();
	});

	it("should have a creation date", function() {
		expect( cell.creation ).toBeDefined();
	});
  
	describe("when a module has been added", function() {
		beforeEach(function() {
			module = jasmine.createSpy('ModuleStub');
			cell.add( module );
		});

		it("should have that module", function() {
			expect( cell.has( module ) ).toBeTruthy();
		});
		
		it("should be able to remove that module", function() {
			cell.remove( module );
			expect( cell.has( module ) ).toBeFalsy();
		});
	});
	
	describe("when a substrate has been added", function() {
		var substrate_name = 'mock';
		var substrate_amount = 42;
		
		beforeEach(function() {
			cell.add_substrate( substrate_name, substrate_amount );
		});
		
		it("should have that substrate", function() {
			expect( cell.amount_of( substrate_name ) ).toBe( substrate_amount );
		});
		
		it("should be able to remove that substrate", function() {
			cell.remove_substrate( substrate_name );
			expect( cell.amount_of( substrate_name ) ).not.toBeDefined();
		});
	});
	
	describe("when the cell has ran", function() {
		var run_t = 10;
		var result = null;
		
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
		var create_transport, transport_food, food_enzym;
		
		var enzym = 1;
		var food = 100;

		beforeEach(function() {
			cell = new Cell();
			cell.add_substrate( 'enzym', enzym )
				.add_substrate( 'food_out', food )
				.add_substrate( 'food_in', 0 )
				
			create_transport = new Module(
				{ rate: 2 }, 
				function ( t, substrates ) {
					return { 'transp' : this.rate }
				},
				{ 'transp' : 0 }
			);

			transport_food = new Module(
				{ rate: 1 },
				function ( t, substrates ) {
					transporters = substrates.transp
					food_out = substrates.food_out
					transport = Math.min( transporters * this.rate, Math.max( 0, food_out ) )
					return { 
						'food_out' : -transport, 
						'food_in' : transport 
					}
				},
				{ }
			);

			food_enzym = new Module(
				{},
				function ( t, substrates ) {

					food_in = substrates.food_in
					enzym = substrates.enzym
					processed = Math.min( enzym, Math.max( 0, food_in ) )
					return { 
						'food_in' : -processed 
					}
				},
				{ }
			);

			cell.add( create_transport )
				.add( transport_food )
				.add( food_enzym )
		});

		describe( "when ran for 0 seconds", function() {
			var results, result, mapping;
			
			beforeEach(function() {
				results = cell.run( 0 );
				console.info( results );
				result = results.results;
				mapping = results.map;
			});
			
			it("should have input values", function() {
				expect( result ).toBeDefined();
				console.info(result.y[ result.y.length - 1 ]);
				console.info(mapping);
				expect( result.y[ result.y.length - 1 ][ mapping.enzym ] ).toBe( enzym );
				expect( result.y[ result.y.length - 1 ][ mapping.food_out ] ).toBe( food );
				expect( result.y[ result.y.length - 1 ][ mapping.food_in ] ).toBe( 0 );
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
				expect( result.y[ result.y.length - 1 ][ mapping.enzym ] ).toBe( enzym );
			});
			
			it("should have created transporters", function() {
				expect( result.y[ result.y.length - 1 ][ mapping.transp ] ).toBe( create_transport.rate * 2 );
			});
			
			it("should have transported food", function() {
				expect( result.y[ result.y.length - 1 ][ mapping.food_in ] ).toBeGreaterThan( 0 );
				expect( result.y[ result.y.length - 1 ][ mapping.food_out ] ).toBeLessThan( food );
			});
			
			it("should have consumed food", function() {
				expect( 
					result.y[ result.y.length - 1 ][ mapping.food_in ] + 
					result.y[ result.y.length - 1 ][ mapping.food_out ] 
				).toBeLessThan( food );
			});
			
		});
		
		describe( "when visualized over 2 second" , function() {
			var container;

			beforeEach(function() {
				container = $("<div class='container'></div>");
				dt = 0.1;
				cell.visualize(2, container);
			});

			it("the container should have as many graphs as the cell has substrates", function() {
				expect( container.children().length ).toBe( 5 );
			});

			xit("", function() {
				expect( 1 ).toBe( 1 );
			});
			
			xit("", function() {
				expect( 1 ).toBe( 1 );
			});
			
			xit("", function() {
				expect( 1 ).toBe( 1 );
			});

		});
	});
});
