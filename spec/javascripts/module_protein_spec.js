describe("Module Protein", function() {
	
	describe( "when using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Protein();
		});
		
		it( "should have 'protein' as name", function() {
			expect( module.name ).toBe( "protein" );
		});
		
		it( "should have 'p_int' as substrate", function() {
			expect( module.substrate ).toBe( "p_int" );
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
		
		describe( "and using named option in the constructor, not as params", function() {
			
			beforeEach( function() {
				module = new Model.Protein( { a: 'new' }, undefined, "food" );
			});
			
			it( "should override default parameters", function() {
				expect( module.substrate ).toMatch( 'food' );
			});
			
		});
		
		describe( "and using named option in the constructor, also as params", function() {
			
			beforeEach( function() {
				module = new Model.Protein( { a: 'new', substrate: 'winner' }, undefined, "loser" );
			});
			
			it( "should not override given params ", function() {
				expect( module.substrate ).toMatch( 'winner' );
			});
			
		});
	});
	
	describe( "when using start in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Protein( undefined, 2 );
		});		
		
		it( "should overide the default start value", function() {
			expect( module.starts.name ).toBe( 2 );
			expect( module.amount ).toBe( 2 );
		});
	});
	
	describe( "when using food in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Protein( undefined, undefined, 'magix' );
		});		
		
		it( "should overide the default food with 'magix'", function() {
			expect( module.substrate ).toMatch( 'magix' );
		});
	});
	
	describe( "when using name in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Protein( undefined, undefined, undefined,  'magix' );
		});		
		
		it( "should overide the name with that name", function() {
			expect( module.name ).toMatch( 'magix' );
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
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna substrate", function() {
			
			beforeEach( function() { 
				substrates[module.dna] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with food substrate", function() {
			
			beforeEach( function() { 
				substrates[module.substrate] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna and food substrate", function() {
		
			beforeEach( function() {
				substrates[module.dna] = 1;
				substrates[module.substrate] = 1;
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
					expect( results[module.substrate] ).toBeLessThan( 0 );
				});
				
				it( "should have substrate = -protein", function() {
					expect( results[module.name] + results[module.substrate] ).toBe( 0 );
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
					
					it( "should decrease substrate", function() {
						expect( results[module.substrate] ).toBeLessThan( 0 );
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
					expect( results[module.substrate] ).toBeLessThan( 0 );
				});
				
				it( "should have substrate = -protein", function() {
					expect( results[module.name] + results[module.substrate] ).toBe( 0 );
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
					
					it( "should decrease substrate", function() {
						expect( results[module.substrate] ).toBeLessThan( 0 );
					});					
				});
			});
			
		});
	});
		
}); 
