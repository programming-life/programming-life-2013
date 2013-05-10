describe("Module Cell Growth", function() {
	
	describe( "When using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.CellGrowth();
		});

		it( "should have 'cell' as name", function() {
			expect( module.name ).toBe( "cell" );
		});

		it( "should have 's#int' as metabolites", function() {
			expect( module.metabolites ).toBeDefined();
			expect( module.metabolites).toMatch( ["s#int"] );
		});

		it( "should have an infrastructure", function() {
			expect( module.infrastructure ).toBeDefined();
			expect( module.infrastructure ).toMatch( [ "lipid", "protein" ] );
		});

		it( "should have 1 substrate: name", function() {
			expect( _(module.starts).size() ).toBe( 1 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
		});

		it( "should have property mu", function() {
			expect( module.mu ).toBeDefined();
			expect( module.mu() ).toBe( 1 );
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
				deserialized = Model.CellGrowth.deserialize( serialized )
				expect( deserialized ).toBeDefined();
				expect( deserialized.constructor.name ).toBe( module.constructor.name )
			});
			
			describe("and when deserialized", function() {
				var deserialized;
				beforeEach( function() {
					deserialized = Model.CellGrowth.deserialize( serialized )
				});
				
				it( "should have 'cell' as name", function() {
					expect( deserialized.name ).toBe( "cell" );
				});

				it( "should have 's#int' as metabolites", function() {
					expect( module.metabolites ).toBeDefined();
					expect( module.metabolites).toMatch( ["s#int"] );
				});

				it( "should have an infrastructure", function() {
					expect( deserialized.infrastructure ).toBeDefined();
					expect( deserialized.infrastructure ).toMatch( [ "lipid", "protein" ] );
				});

				it( "should have 1 substrate: name", function() {
					expect( _(deserialized.starts).size() ).toBe( 1 );
					expect( deserialized.starts.name ).toBeDefined();
					expect( deserialized.starts.name ).toBe( 1 );
				});
				
				it( "should have a _step function", function() {
					expect( deserialized._step ).toBeDefined();
				});
			});
		});

	});

	describe( "When using params in the constructor", function() {

		var module;
		beforeEach( function() {
			module = new Model.CellGrowth( { a: "new", name: "override_cell" }  );
		});

		it( "should have the new parameters", function() {
			expect( module.a ).toBeDefined();
			expect( module.a ).toMatch( 'new' );
		});
		
		it( "should overide default parameters", function() {
			expect( module.name ).toMatch( 'override_cell' );
		});
		
	});

	describe( "when using start in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.CellGrowth( undefined, 2 );
		});		
		
		it( "should overide the default start value", function() {
			expect( module.starts.name ).toBe( 2 );
			expect( module.amount ).toBe( 2 );
		});
	});


}); 
