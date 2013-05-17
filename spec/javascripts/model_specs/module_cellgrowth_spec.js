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
		});

		describe( "when there are no compounds", function() {

			var compounds, result, module;

			beforeEach( function() {
				compounds = {};
				module = new Model.CellGrowth();
				result = module.mu( compounds );
			});

			it( "mu should return 0", function() {
				expect( result ).toBe( 0 );
			});

			describe( "when there is infrastructure", function() {
				
				beforeEach( function() {
					compounds[ module.infrastructure[0] ] = 2;
      				compounds[ module.infrastructure[1] ] = 4;
      				result = module.mu( compounds );
				});

				it( "should return 0", function() {
					expect( result ).toBe( 0 );
				});
			});

			describe( "when there are metabolites", function() {

				beforeEach( function() {
					compounds[ module.metabolites[0] ] = 2;
					result = module.mu( compounds );
				});

				it( "should return 0", function() {
					expect( result ).toBe( 0 );
				});
			});

			describe( "when there is infrastructure and metabolites", function() {

				beforeEach( function(){
					compounds[ module.infrastructure[0] ] = 2;
      				compounds[ module.infrastructure[1] ] = 4;
      				compounds[ module.metabolites[0] ] = 2;
					result = module.mu( compounds );
				});

				it( "should return 64", function() {
					expect( result ).toBe( 16 );
				});
			});
		});

		
		
		it( "should be able to serialize the module", function() {
			serialized = module.serialize( true )
			expect( serialized ).toBeDefined();
			expect( serialized.length ).toBeGreaterThan( 2 )
		});

		
		describe( "and when serialized", function() {

			var serialized;

			beforeEach( function() {
				serialized = module.serialize( true )
			});
			
			it( "should be able to deserialize", function() {
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

	describe( "when stepping", function(){

		var module, result, compounds;

		beforeEach( function() {
			compounds = {};
			module = new Model.CellGrowth();
		});

		describe( "with no compounds", function() {

			beforeEach( function() {
				result = module.step(0, compounds, 0);
			});

			it( "should not have results", function() {
				expect( _(result).isEmpty() ).toBeTruthy();
			});

		});

		describe( "with an infrastructure", function() {

			beforeEach( function() {
				compounds[ module.infrastructure[0] ] = 2;
				compounds[ module.infrastructure[1] ] = 4;
				result = module.step( 0, compounds, 0 );
			});

			it( "should not have results", function() {
				expect( _(result).isEmpty() ).toBeTruthy();
			});
			
		});

		describe( "with metabolites", function() {

			beforeEach( function(){
				compounds[ module.metabolites[0] ] = 2;
				result = module.step( 0, compounds, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(result).isEmpty() ).toBeTruthy();
			});
		});

		describe( "with and infrastructure and metabolites", function(){

			beforeEach( function(){
				compounds[ module.infrastructure[0] ] = 2;
				compounds[ module.infrastructure[1] ] = 4;
				compounds[ module.metabolites[0] ] = 2;
				compounds[ module.name ] = 1;
			});

			describe( "with growthrate > 0", function(){

				beforeEach( function(){
					result = module.step( 0, compounds, .5 );
				});

				it( "should have results", function(){
					expect( _(result).isEmpty() ).toBeFalsy();
				});

				it( "should have decreased population size", function() {
					expect( result[module.name] ).toBeGreaterThan( 0 );
				});
				
			});
		});

	});

}); 
