describe("Module DNA", function() {
	
	describe( "when using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.DNA();
		});
		
		it( "should have 'dna' as name", function() {
			expect( module.name ).toBe( "dna" );
		});
		
		it( "should have 'p#int' as consume", function() {
			expect( module.consume ).toMatch( ["p#int"] );
		});
		
		it( "should have 1 as k (transcription value)", function() {
			expect( module.k ).toBe( 1 );
		});
		
		it( "should have 1 substrate: name with value 1", function() {
			expect( _(module.starts).size() ).toBe( 1 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
			expect( module.amount ).toBe( 1 );
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
				deserialized = Model.DNA.deserialize( serialized )
				expect( deserialized ).toBeDefined();
				expect( deserialized.constructor.name ).toBe( module.constructor.name )
			});
			
			describe("and when deserialized", function() {
				var deserialized;
				beforeEach( function() {
					deserialized = Model.DNA.deserialize( serialized )
				});
				
				it( "should have 'dna' as name", function() {
					expect( module.name ).toBe( "dna" );
				});
				
				it( "should have 'p#int' as consume", function() {
					expect( module.consume ).toMatch( [ "p#int" ] );
				});
				
				it( "should have 1 as k (transcription value)", function() {
					expect( module.k ).toBe( 1 );
				});
				
				it( "should have 1 substrate: name with value 1", function() {
					expect( _(module.starts).size() ).toBe( 1 );
					expect( module.starts.name ).toBeDefined();
					expect( module.starts.name ).toBe( 1 );
					expect( module.amount ).toBe( 1 );
				});
				
				it( "should have a _step function", function() {
					expect( deserialized._step ).toBeDefined();
				});
			});
		});
		
	});
			
	describe( "when using params in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.DNA( { a: 'new', name: 'override_dna' } );
		});
		
		it( "should have the new parameters", function() {
			expect( module.a ).toBeDefined();
			expect( module.a ).toMatch( 'new' );
		});
		
		it( "should overide default parameters", function() {
			expect( module.name ).toMatch( 'override_dna' );
		});
		
	});
	
	describe( "when stepping", function() {
		
		var module, results;
		var substrates;
		
		beforeEach( function() { 
			substrates = {};
			module = new Model.DNA();
		});
		
		describe( "with no substrates", function() {
			
			beforeEach( function() { 
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna substrate", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with food substrate", function() {
			
			beforeEach( function() { 
				substrates[module.consume[0]] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna and food substrate", function() {
		
			beforeEach( function() {
				substrates[module.name] = 1;
				substrates[module.consume[0]] = 1;
			});
			
			describe( "with growth_rate > 0", function() {
			
				beforeEach( function() {
					results = module.step( 0, substrates, .5 );
				});
				
				it( "should have results", function() {
					expect( _(results).isEmpty() ).toBeFalsy();
				});
			
				it( "should increase dna", function() {
					expect( results[module.name] ).toBeGreaterThan( 0 );
				});
				
				it( "should decrease food", function() {
					expect( results[module.consume[0]] ).toBeLessThan( 0 );
				});
				
				it( "should have -food > dna (dillution)", function() {
					expect( - results[module.consume[0]] + results[module.name]  ).toBeGreaterThan( 0 );
				});
			});
			
			describe( "with growth_rate = 0", function() {
			
				beforeEach( function() {
					results = module.step( 0, substrates, 0 );
				});
			
				it( "should have results", function() {
					expect( _(results).isEmpty() ).toBeFalsy();
				});
				
				it( "should increase dna", function() {
					expect( results[module.name] ).toBeGreaterThan( 0 );
				});
				
				it( "should decrease food", function() {
					expect( results[module.consume[0]] ).toBeLessThan( 0 );
				});
				
				it( "should have food = -dna (no dillution)", function() {
					expect( results[module.consume[0]] + results[module.name]  ).toBe( 0 );
				});
			});
			
		});
	});
		
}); 
