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
			expect( result.x ).toBeDefined();
			expect( result.x[ 0 ] ).toBe( 0 );
			expect( result.x[ result.x.length - 1 ] ).toBe( run_t );
			
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
				.add_substrate( 'transp', 0 );
			
			create_transport = new Module(
				{ rate: 2 }, 
				function ( t, substrates ) {
					return { 'transp' : this.rate }
				}
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
				}
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
				}
			);

			cell.add( create_transport )
				.add( transport_food )
				.add( food_enzym )
		});

		describe( "when ran for 0 seconds", function() {
			var result;
			
			beforeEach(function() {
				result = cell.run( 0 );
			});
			
			it("should have input values", function() {
				expect( result ).toBeDefined();
				expect( result.y[ result.y.length - 1 ][0] ).toBe( enzym );
				expect( result.y[ result.y.length - 1 ][1] ).toBe( food );
				expect( result.y[ result.y.length - 1 ][2] ).toBe( 0 );
				expect( result.y[ result.y.length - 1 ][3] ).toBe( 0 );
			});
			
		});
		
		describe( "when ran for 2 seconds", function() {
			var result;
			
			beforeEach(function() {
				result = cell.run( 2 );
			});
			
			it("should have kept all the enzym", function() {
				expect( result.y[ result.y.length - 1 ][0] ).toBe( enzym );
			});
			
			it("should have created transporters", function() {
				expect( result.y[ result.y.length - 1 ][3] ).toBe( create_transport.rate * 2 );
			});
			
			it("should have transported food", function() {
				expect( result.y[ result.y.length - 1 ][2] ).toBeGreaterThan( 0 );
				expect( result.y[ result.y.length - 1 ][1] ).toBeLessThan( food );
			});
			
			it("should have consumed food", function() {
				expect( 
					result.y[ result.y.length - 1 ][2] + 
					result.y[ result.y.length - 1 ][1] 
				).toBeLessThan( food );
			});
			
		});
		
	});
	
});