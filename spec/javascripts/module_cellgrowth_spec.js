describe("Module Cell Growth", function() {
	
	describe( "When using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.CellGrowth();
		});

		it( "should have 'cell' as name", function() {
			expect( module.name ).toBe( "cell" );
		});

		it( "should have 's_int' as consume", function() {
			expect( module.consume ).toBe( "s_int" );
		});

		it( "should have an infrastructure", function() {
			expect( module.infrastructure ).toBeDefined();
			expect( module.infrastructure ).toMatch( [ "lipid", "protein" ] );
		});

		it( "should have 1 substrate: name", function() {
			expect( _(module.starts).size() ).toBe( 1 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
		})
		
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

				it( "should have 's_int' as consume", function() {
					expect( deserialized.consume ).toBe( "s_int" );
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

}); 
