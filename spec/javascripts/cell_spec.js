describe("Cell", function() {
	var cell;
	var module;

	beforeEach(function() {
		cell = new Model.Cell();
	});

	it("should have a creation date", function() {
		expect( cell.creation ).toBeDefined();
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
			cell.addSubstrate( substrate_name, substrate_amount );
		});
		
		it("should have that substrate", function() {
			expect( cell.hasSubstrate( substrate_name ) ).toBeTruthy();
			substrate = cell.getSubstrate( substrate_name );
			expect( substrate ).toBeDefined();
			expect( substrate ).not.toBe( null );
		});
		
		it("should have the amount specified", function() {
			expect( cell.amountOf( substrate_name ) ).toBe( substrate_amount );
			substrate = cell.getSubstrate( substrate_name );
			expect( substrate.amount ).toBe( substrate_amount );
		})

		it("should replace the substrate amount if it already exists", function () {
			substrate = cell.getSubstrate( substrate_name );
			cell.addSubstrate( substrate_name, substrate_amount + 1 );
			expect( substrate ).toBe( cell.getSubstrate( substrate_name ) );
			expect( cell.amountOf( substrate_name ) ).toBe( substrate_amount + 1 );
			expect( substrate.amount ).toBe( substrate_amount + 1 );
		});
		
		it("should be able to remove that substrate", function() {
			cell.removeSubstrate( substrate_name );
			expect( cell.hasSubstrate( substrate_name ) ).toBeFalsy();
			expect( cell.getSubstrate( substrate_name ) ).toBeNull();
			expect( cell.amountOf( substrate_name ) ).not.toBeDefined();
		});

		it("can be an external substrate", function() {
			cell.addSubstrate( 'e_substrate', substrate_amount, false, false );
			expect( cell.hasSubstrate( 'e_substrate' ) ).toBeTruthy();
			substrate = cell.getSubstrate( 'e_substrate' );
			expect( substrate.placement ).toBeAtMost( -1 );
		});
		
		it("can be an internal substrate", function() {
			cell.addSubstrate( 'i_substrate', substrate_amount, true, false );
			expect( cell.hasSubstrate( 'i_substrate' ) ).toBeTruthy();
			substrate = cell.getSubstrate( 'i_substrate' );
			expect( substrate.placement ).toBeBetween( -1, 0 );
		});

		it("can be an internal product", function() {
			cell.addSubstrate( 'i_product', substrate_amount, true, true );
			expect( cell.hasSubstrate( 'i_product' ) ).toBeTruthy();
			substrate = cell.getSubstrate( 'i_product' );
			expect( substrate.placement ).toBeBetween( 0, 1 );
		});
		
		it("can be an external product", function() {
			cell.addSubstrate( 'e_product', substrate_amount, false, true );
			expect( cell.hasSubstrate( 'e_product' ) ).toBeTruthy();
			substrate = cell.getSubstrate( 'e_product' );
			expect( substrate.placement ).toBeAtLeast( 1 );
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
		var create_transport, transport_food, food_enzym;
		
		var enzym = 1;
		var food = 100;

		beforeEach(function() {
			cell = new Model.Cell();
			cell.addSubstrate( 'enzym', enzym )
				.addSubstrate( 'food_out', food )
				.addSubstrate( 'food_in', 0 )
				
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

			food_enzym = new Model.Module(
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
			var results, result, mapping;
			
			beforeEach(function() {
				results = cell.run( 0 );
				result = results.results;
				mapping = results.map;
			});
			
			it("should have input values", function() {
				expect( result ).toBeDefined();
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
		
		describe( "when visualized over 2 second" , function() {
			var container;

			beforeEach(function() {
				container = $("<div class='container'></div>");
				cell.visualize( 2, container );
			});

			it("the container should have as many graphs as the cell has substrates", function() {
				expect( container.children().length ).toBe( 5 );
			});

		});
		
		xit( "serialized and deserilized, should retain substrates, modules, cell", function() {
		
		});
	});
	
	
});
