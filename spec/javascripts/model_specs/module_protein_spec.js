describe("Module Protein", function() {
	
	describe( "when using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Protein();
		});
		
		it( "should have 'complex' as name", function() {
			expect( module.name ).toBe( "complex" );
		});
		
		it( "should have 'p#int' as consume", function() {
			expect( module.consume ).toMatch( ["p#int"] );
		});
		
		it( "should have 1 as k (transcription value)", function() {
			expect( module.k ).toBe( 1 );
		});
		
		it( "should have 1 as k_d (degrade value)", function() {
			expect( module.k_d ).toBe( 1 );
		});
		
		it( "should have 'dna' as dna", function() {
			expect( module.dna ).toBe( "dna" );
		});
		
		it( "should have 1 substrate: name with value 0", function() {
			expect( _(module.starts).size() ).toBe( 1 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 0 );
			expect( module.amount ).toBe( 0 );
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
				deserialized = Model.Protein.deserialize( serialized )
				expect( deserialized ).toBeDefined();
				expect( deserialized.constructor.name ).toBe( module.constructor.name )
			});
			
			describe("and when deserialized", function() {
				var deserialized;
				beforeEach( function() {
					deserialized = Model.Protein.deserialize( serialized )
				});
				
				it( "should have 'complex' as name", function() {
					expect( module.name ).toBe( "complex" );
				});
				
				it( "should have 'p#int' as consume", function() {
					expect( module.consume ).toMatch( ["p#int"] );
				});
				
				it( "should have 1 as k (transcription value)", function() {
					expect( module.k ).toBe( 1 );
				});
				
				it( "should have 1 as k_d (degrade value)", function() {
					expect( module.k_d ).toBe( 1 );
				});
				
				it( "should have 'dna' as dna", function() {
					expect( module.dna ).toBe( "dna" );
				});
				
				it( "should have 1 substrate: name with value 0", function() {
					expect( _(module.starts).size() ).toBe( 1 );
					expect( module.starts.name ).toBeDefined();
					expect( module.starts.name ).toBe( 0 );
					expect( module.amount ).toBe( 0 );
				});
				
				it("should be able to serialize the module", function() {
					serialized = module.serialize( true )
					expect( serialized ).toBeDefined();
					expect( serialized.length ).toBeGreaterThan( 2 )
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
			module = new Model.Protein( { a: 'new', dna: 'override_dna' } );
		});
		
		it( "should have the new parameters", function() {
			expect( module.a ).toBeDefined();
			expect( module.a ).toMatch( 'new' );
		});
		
		it( "should overide default parameters", function() {
			expect( module.dna ).toMatch( 'override_dna' );
		});
		
	});
	
	describe( "when stepping", function() {
		
		var module, results;
		var substrates;
		
		beforeEach( function() { 
			substrates = {};
			module = new Model.Protein( { k_d: .5 } );
		});
		
		describe( "with no substrates", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 0
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna substrate", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 0
				substrates[module.dna] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with food substrate", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 0
				substrates[module.consume[0]] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna and food substrate", function() {
		
			beforeEach( function() {
				substrates[module.name] = 0
				substrates[module.dna] = 1;
				substrates[module.consume[0]] = 1;
			});
			
			describe( "with growth_rate > 0", function() {
			
				beforeEach( function() {
					results = module.step( 0, substrates, 1 );
				});
				
				it( "should have results", function() {
					expect( _(results).isEmpty() ).toBeFalsy();
				});
			
				it( "should increase protein", function() {
					expect( results[module.name] ).toBeGreaterThan( 0 );
				});
				
				it( "should decrease substrate", function() {
					expect( results[module.consume[0]] ).toBeLessThan( 0 );
				});
				
				it( "should have substrate = -protein", function() {
					expect( results[module.name] + results[module.consume[0]] ).toBe( 0 );
				});
				
				describe( "and protein > 0", function() {
					
					beforeEach( function() {
						substrates[module.name] = 1;
						results = module.step( 0, substrates, 1 );
					});
					
					it( "should have results", function() {
						expect( _(results).isEmpty() ).toBeFalsy();
					});
				
					it( "should increase protein less than 1", function() {
						expect( results[module.name] ).toBeLessThan( 1 );
					});
					
					it( "should decrease protein", function() {
						expect( results[module.name] ).toBeLessThan( 0 );
					});
					
					it( "should decrease consume", function() {
						expect( results[module.consume[0]] ).toBeLessThan( 0 );
					});					
				});
			});
			
			describe( "with growth_rate = 0", function() {
			
				beforeEach( function() {
					results = module.step( 0, substrates, 0 );
				});
			
				it( "should have results", function() {
					expect( _(results).isEmpty() ).toBeFalsy();
				});
				
				it( "should increase protein", function() {
					expect( results[module.name] ).toBeGreaterThan( 0 );
				});
				
				it( "should decrease food", function() {
					expect( results[module.consume[0]] ).toBeLessThan( 0 );
				});
				
				it( "should have substrate = -protein", function() {
					expect( results[module.name] + results[module.consume[0]] ).toBe( 0 );
				});
				
				describe( "and protein > 0", function() {
					
					beforeEach( function() {
						substrates[module.name] = 1;
						results = module.step( 0, substrates, 0 );
					});
					
					it( "should have results", function() {
						expect( _(results).isEmpty() ).toBeFalsy();
					});
				
					it( "should increase protein less than 1", function() {
						expect( results[module.name] ).toBeLessThan( 1 );
					});
					
					it( "should increase protein more than when mu > 0", function() {
						expect( results[module.name] ).toBeGreaterThan( 0 );
					});
					
					it( "should decrease consume", function() {
						expect( results[module.consume[0]] ).toBeLessThan( 0 );
					});					
				});
			});
			
		});
	});
		
}); 
