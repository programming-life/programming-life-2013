describe( "Module Substrate", function() {

	describe( "When using default constructor", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate();
		});

		it( "should have no name", function() {
			expect( module.name ).toBe( undefined );
		});

		it( "should be inside the cell", function() {
			expect( module.placement ).toBeBetween( -1, 1 );
		});
		
		it( "should be inside a substrate", function() {
			expect( module.placement ).toBeAtMost( 0 );
		});

		it( "should have 1 substrate: name with value 1", function() {
			expect( _( module.starts ).size() ).toBe( 1 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
		});
		
		it("should be able to serialize the module", function() {
			serialized = module.serialize( true )
			expect( serialized ).toBeDefined();
			expect( serialized.length ).toBeGreaterThan( 2 )
		});
		
		describe("and when serialized", function() {
			var serialized;
			beforeEach( function() {
				serialized = module.serialize( true )
			});
			
			it("should be able to deserialize", function() {
				deserialized = Model.Substrate.deserialize( serialized )
				expect( deserialized ).toBeDefined();
				expect( deserialized.constructor.name ).toBe( module.constructor.name )
			});
			
			describe("and when deserialized", function() {
				var deserialized;
				beforeEach( function() {
					deserialized = Model.Substrate.deserialize( serialized )
				});
				
				it( "should have no name", function() {
					expect( module.name ).toBe( undefined );
				});

				it( "should be inside the cell", function() {
					expect( module.placement ).toBeBetween( -1, 1 );
				});
				
				it( "should be inside a substrate", function() {
					expect( module.placement ).toBeAtMost( 0 );
				});

				it( "should have 1 substrate: name with value 1", function() {
					expect( _( module.starts ).size() ).toBe( 1 );
					expect( module.starts.name ).toBeDefined();
					expect( module.starts.name ).toBe( 1 );
				});
		
				it( "should have a _step function", function() {
					expect( deserialized._step ).toBeDefined();
				});
			});
		});

	});

	describe( "When using parameters in the constructor", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate( { x: "new", name: "override_substrate" } );
		});

		it( "should have the new parameters" , function() {
			expect( module.x ).toBeDefined();
			expect( module.x ).toBe( "new" );
		})

		it( "should override default parameters", function() {
			expect( module.name ).toBe( "override_substrate" );
		});

	});

	describe( "When using name option, not as parameter", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate( undefined, undefined, "named_substrate");
		});

		it( "should override the default name", function() {
			expect( module.name ).toBe( "named_substrate" );
		});

	});

	describe( "When using name option and as parameter", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate( { name: "param_substrate"}, undefined, "named_substrate" );
		});

		it( "should not override parameterized name", function() {
			expect( module.name ).toBe( "param_substrate" );
		});
	});

	describe( "When using the start option", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate( undefined, 2 );
		});

		it( "should override the default value", function(){
			expect( module.starts.name ).toBe( 2 );
		});
		
	});
	
	describe( "When using the inside_cell option", function() {

		describe( "and inside_cell", function() {
			
			var module;
			beforeEach( function() {
				module = new Model.Substrate( undefined, 2, undefined, true );
			});

			it( "should have the correct placement", function(){
				expect( module.placement ).toBeBetween( -1, 1 );
			});
		});
		
		describe( "and not inside_cell", function() {
			
			var module;
			beforeEach( function() {
				module = new Model.Substrate( undefined, 2, undefined, false );
			});

			it( "should have the correct placement", function(){
				expect( module.placement ).not.toBeBetween( -1, 1 );
			});
		});
		
	});
	
	describe( "When using the is_product option", function() {

		describe( "and is_product", function() {
			
			var module;
			beforeEach( function() {
				module = new Model.Substrate( undefined, 2, undefined, undefined, true );
			});

			it( "should have the correct placement", function(){
				expect( module.placement ).toBeGreaterThan( 0 );
			});
		});
		
		describe( "and not is_product", function() {
			
			var module;
			beforeEach( function() {
				module = new Model.Substrate( undefined, 2, undefined, undefined, false );
			});

			it( "should have the correct placement", function(){
				expect( module.placement ).toBeLessThan( 0 );
			});
		});
	});
});