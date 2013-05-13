describe("Module Lipid", function() {
	
	describe( "when using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Lipid();
		});
		
		it( "should have 'lipid' as name", function() {
			expect( module.name ).toBe( "lipid" );
		});
		
		it( "should have 's#int' as consume", function() {
			expect( module.consume ).toMatch( ["s#int"] );
		});
		
		it( "should have 1 as k (transcription value)", function() {
			expect( module.k ).toBe( 1 );
		});
		
		it( "should have 'dna' as dna", function() {
			expect( module.dna ).toBe( "dna" );
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
				deserialized = Model.Lipid.deserialize( serialized )
				expect( deserialized ).toBeDefined();
				expect( deserialized.constructor.name ).toBe( module.constructor.name )
			});
			
			describe("and when deserialized", function() {
				var deserialized;
				beforeEach( function() {
					deserialized = Model.Lipid.deserialize( serialized )
				});
				
				it( "should have 'lipid' as name", function() {
					expect( module.name ).toBe( "lipid" );
				});
				
				it( "should have 's#int' as consume", function() {
					expect( module.consume ).toMatch( ["s#int"] );
				});
				
				it( "should have 1 as k (transcription value)", function() {
					expect( module.k ).toBe( 1 );
				});
				
				it( "should have 'dna' as dna", function() {
					expect( module.dna ).toBe( "dna" );
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
			module = new Model.Lipid( { a: 'new', dna: 'override_dna' } );
		});
		
		it( "should have the new parameters", function() {
			expect( module.a ).toBeDefined();
			expect( module.a ).toMatch( 'new' );
		});
		
		it( "should overide default parameters", function() {
			expect( module.dna ).toMatch( 'override_dna' );
		});
		
		describe( "when using named option in the constructor, not as params", function() {
			
			beforeEach( function() {
				module = new Model.Lipid( { a: 'new' }, undefined, "p_int" );
			});
			
			it( "should override default parameters", function() {
				expect( module.consume ).toMatch( 'p_int' );
			});
			
		});
		
		describe( "when using named option in the constructor, also as params", function() {
			
			beforeEach( function() {
				module = new Model.Lipid( { a: 'new', consume: 'stubborn' }, undefined, "override" );
			});
			
			it( "should not override given params ", function() {
				expect( module.consume ).toMatch( 'stubborn' );
			});
			
		});
	});
	
	describe( "when using start in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Lipid( undefined, 2 );
		});		
		
		it( "should overide the default start value", function() {
			expect( module.starts.name ).toBe( 2 );
			expect( module.amount ).toBe( 2 );
		});
	});
	
	describe( "when using food in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Lipid( undefined, undefined, 'magix' );
		});		
		
		it( "should overide the consume with that food", function() {
			expect( module.consume ).toMatch( ['magix'] );
		});
	});
	
	describe( "when stepping", function() {
		
		var module, results;
		var substrates;
		
		beforeEach( function() { 
			substrates = {};
			module = new Model.Lipid();
		});
		
		describe( "with no substrates", function() {
			
			
			
			beforeEach( function() { 
				substrates[module.name] = 0;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna substrate", function() {
			
			beforeEach( function() { 
				substrates[module.dna] = 1;
				substrates[module.name] = 0;
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
				substrates[module.dna] = 1;
				substrates[module.name] = 0;
				substrates[module.consume[0]] = 1;
			});
			
			describe( "with growth_rate > 0", function() {
			
				beforeEach( function() {
					results = module.step( 0, substrates, 1 );
				});
				
				it( "should have results", function() {
					expect( _(results).isEmpty() ).toBeFalsy();
				});
			
				it( "should increase lipid", function() {
					expect( results[module.name] ).toBeGreaterThan( 0 );
				});
				
				it( "should decrease food", function() {
					expect( results[module.consume[0]] ).toBeLessThan( 0 );
				});
				
				it( "should have lipid = -food", function() {
					expect( results[module.name] + results[module.consume] ).toBe( 0 );
				});
				
				describe( "and with lipid > 0", function() {
					beforeEach( function() {
						substrates[module.name] = 1;
						results = module.step( 0, substrates, 1 );
					});
					
					it( "should have lipid < -food", function() {
						expect( results[module.name] + results[module.consume[0]] ).toBeLessThan( 0 );
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
				
				it( "should increase lipid", function() {
					expect( results[module.name] ).toBeGreaterThan( 0 );
				});
				
				it( "should decrease food", function() {
					expect( results[module.consume[0]] ).toBeLessThan( 0 );
				});
				
				it( "should have lipid = -food", function() {
					expect( results[module.name] + results[module.consume] ).toBe( 0 );
				});
				
				describe( "and with lipid > 0", function() {
					beforeEach( function() {
						substrates[module.name] = 1;
						results = module.step( 0, substrates, 0 );
					});
					
					it( "should have lipid = -food", function() {
						expect( results[module.name] + results[module.consume[0]] ).toBe( 0 );
					});
				});
			});
		});
	});
}); 
