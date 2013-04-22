describe("Module DNA", function() {
	
	describe( "when using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.DNA();
		});
		
		it( "should have 'dna' as name", function() {
			expect( module.name ).toBe( "dna" );
		});
		
		it( "should have 'p_int' as consume", function() {
			expect( module.consume ).toBe( "p_int" );
		});
		
		it( "should have 1 as k (transcription value)", function() {
			expect( module.k ).toBe( 1 );
		});
		
		it( "should have 1 substrate: name with value 1", function() {
			expect( _(module.substrates).size() ).toBe( 1 );
			expect( module.substrates[module.name] ).toBeDefined();
			expect( module.substrates[module.name] ).toBe( 1 );
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
		
		describe( "when using named option in the constructor, not as params", function() {
			
			beforeEach( function() {
				module = new Model.DNA( { a: 'new' }, undefined, "prefix" );
			});
			
			it( "should override default parameters", function() {
				expect( module.name ).toMatch( 'prefix_dna' );
			});
			
		});
		
		describe( "when using named option in the constructor, also as params", function() {
			
			beforeEach( function() {
				module = new Model.DNA( { a: 'new', name: 'override_dna' }, undefined, "prefix" );
			});
			
			it( "should not override given params ", function() {
				expect( module.name ).toMatch( 'override_dna' );
			});
			
		});
	});
	
	describe( "when using start in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.DNA( undefined, 2 );
		});		
		
		it( "should overide the default start value", function() {
			expect( module.substrates[module.name] ).toBe( 2 );
		});
	});
	
	describe( "when using prefix in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.DNA( undefined, undefined, 'prefix' );
		});		
		
		it( "should overide the default name with 'prefix_dna'", function() {
			expect( module.name ).toMatch( 'prefix_dna' );
		});
	});
	
	describe( "when using food in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.DNA( undefined, undefined, undefined, 'magix' );
		});		
		
		it( "should overide the consume with that food", function() {
			expect( module.consume ).toMatch( 'magix' );
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
				substrates[module.consume] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna and food substrate", function() {
		
			beforeEach( function() {
				substrates[module.name] = 1;
				substrates[module.consume] = 1;
			});
			
			describe( "with growth_rate > 0", function() {
			
				beforeEach( function() {
					results = module.step( 0, substrates, 1 );
				});
				
				it( "should have results", function() {
					expect( _(results).isEmpty() ).toBeFalsy();
				});
			
				it( "should increase dna", function() {
					expect( results[module.name] ).toBeGreaterThan( 0 );
				});
				
				it( "should decrease food", function() {
					expect( results[module.consume] ).toBeLessThan( 0 );
				});
			});
			
			describe( "with growth_rate = 0", function() {
			
				beforeEach( function() {
					results = module.step( 0, substrates, 0 );
				});
			
				it( "should have results", function() {
					expect( _(results).isEmpty() ).toBeFalsy();
				});
				
				it( "should not increase dna", function() {
					expect( results[module.name] ).toBe( 0 );
				});
				
				it( "should decrease food", function() {
					expect( results[module.consume] ).toBeLessThan( 0 );
				});
			});
			
		});
	});
		
}); 
