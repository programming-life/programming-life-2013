describe("Module Metabolism", function() {
	
	describe( "when using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Metabolism();
		});
		
		it( "should have 'enzyme' as name", function() {
			expect( module.name ).toBe( "enzyme" );
		});
		
		it( "should have 's_int' as substrate", function() {
			expect( module.orig ).toBe( "s_int" );
		});
		
		it( "should have 'p_int' as product", function() {
			expect( module.dest ).toBe( "p_int" );
		});
		
		it( "should have 1 as k (transcription value)", function() {
			expect( module.k ).toBe( 1 );
		});
		
		it( "should have 1 as k_m (reaction value)", function() {
			expect( module.k_m ).toBe( 1 );
		});
		
		it( "should have 1 as k_d (degration value)", function() {
			expect( module.k_d ).toBe( 1 );
		});
		
		it( "should have 1 as v (speed scale vmax)", function() {
			expect( module.v ).toBe( 1 );
		});
		
		it( "should have 'dna' as dna", function() {
			expect( module.dna ).toBe( "dna" );
		});
		
		it( "should have 2 substrates: dest and enzym", function() {
			expect( _(module.starts).size() ).toBe( 2 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 0 );
			expect( module.amount ).toBe( 0 );
			expect( module.starts.dest ).toBeDefined();
			expect( module.starts.dest ).toBe( 0 );
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
				deserialized = Model.Metabolism.deserialize( serialized )
				expect( deserialized ).toBeDefined();
				expect( deserialized.constructor.name ).toBe( module.constructor.name )
			});
			
			describe("and when deserialized", function() {
				var deserialized;
				beforeEach( function() {
					deserialized = Model.Metabolism.deserialize( serialized )
				});
				
				it( "should have 'enzyme' as name", function() {
					expect( module.name ).toBe( "enzyme" );
				});
				
				it( "should have 's_int' as substrate", function() {
					expect( module.orig ).toBe( "s_int" );
				});
				
				it( "should have 'p_int' as product", function() {
					expect( module.dest ).toBe( "p_int" );
				});
				
				it( "should have 1 as k (transcription value)", function() {
					expect( module.k ).toBe( 1 );
				});
				
				it( "should have 1 as k_m (reaction value)", function() {
					expect( module.k_m ).toBe( 1 );
				});
				
				it( "should have 1 as k_d (degration value)", function() {
					expect( module.k_d ).toBe( 1 );
				});
				
				it( "should have 1 as v (speed scale vmax)", function() {
					expect( module.v ).toBe( 1 );
				});
				
				it( "should have 'dna' as dna", function() {
					expect( module.dna ).toBe( "dna" );
				});
				
				it( "should have 2 substrates: dest and enzym", function() {
					expect( _(module.starts).size() ).toBe( 2 );
					expect( module.starts.name ).toBeDefined();
					expect( module.starts.name ).toBe( 0 );
					expect( module.amount ).toBe( 0 );
					expect( module.starts.dest ).toBeDefined();
					expect( module.starts.dest ).toBe( 0 );
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
			module = new Model.Metabolism( { a: 'new', dna: 'override_dna' } );
		});
		
		it( "should have the new parameters", function() {
			expect( module.a ).toBeDefined();
			expect( module.a ).toMatch( 'new' );
		});
		
		it( "should overide default parameters", function() {
			expect( module.dna ).toMatch( 'override_dna' );
		});
		
		describe( "and using named option in the constructor, but not as params", function() {
			
			beforeEach( function() {
				module = new Model.Metabolism( { a: 'new' }, undefined, "f_int" );
			});
			
			it( "should override default parameters", function() {
				expect( module.orig ).toMatch( 'f_int' );
			});
			
		});
		
		describe( "and using named option in the constructor, also as params", function() {
			
			beforeEach( function() {
				module = new Model.Metabolism( { a: 'new', orig: 'stubborn' }, undefined, "override" );
			});
			
			it( "should not override given params ", function() {
				expect( module.orig ).toMatch( 'stubborn' );
			});
			
		});
	});
	
	describe( "when using start in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Metabolism( undefined, 2 );
		});		
		
		it( "should overide the default start value", function() {
			expect( module.starts.name ).toBe( 2 );
			expect( module.amount ).toBe( 2 );
		});
	});
	
	describe( "when using substrate in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Metabolism( undefined, undefined, 'magix' );
		});		
		
		it( "should overide the orig with that substrate", function() {
			expect( module.orig ).toMatch( 'magix' );
		});
	});
	
	describe( "when using product in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Metabolism( undefined, undefined, undefined, 'magix' );
		});		
		
		it( "should overide the dest with that substrate", function() {
			expect( module.dest ).toMatch( 'magix' );
		});
	});
	
	describe( "when using name in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Metabolism( undefined, undefined, undefined, undefined, 'magix' );
		});		
		
		it( "should overide the name with that substrate", function() {
			expect( module.name ).toMatch( 'magix' );
		});
	});
	
	describe( "when stepping", function() {
		
		var module, results;
		var substrates;
		
		beforeEach( function() { 
			substrates = {};
			module = new Model.Metabolism();
			module.k_d = .5;
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
			
			it( "should have results", function() {
				expect( _(results).isEmpty() ).toBeFalsy();
			});
			
			it( "should have enzym created", function() {
				expect( results[module.name] ).toBeGreaterThan( 0 );
			});
		});
		
		describe( "with enzym substrate", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with enzym and orig substrate", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 1;
				substrates[module.orig] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should have results", function() {
				expect( _(results).isEmpty() ).toBeFalsy();
			});
			
			it( "should have dest created", function() {
				expect( results[module.dest] ).toBeGreaterThan( 0 );
			});
			
			it( "should have orig removed", function() {
				expect( results[module.orig] ).toBeLessThan( 0 );
			});
			
			
			it( "should have orig = -dest", function() {
				expect( results[module.orig] + results[module.dest]  ).toBe( 0 );
			});
		
			describe( "and dna substrate", function() {
			
				beforeEach( function() {
					substrates[module.dna] = 1;
				});
			
				describe( "with growth_rate > 0", function() {
				
					beforeEach( function() {
						results = module.step( 0, substrates, 1 );
					});
				
					it( "should have results", function() {
						expect( _(results).isEmpty() ).toBeFalsy();
					});
			
					it( "should decrease enzym", function() {
						expect( results[module.name] ).toBeLessThan( 0 );
					});
				
					it( "should decrease orig", function() {
						expect( results[module.orig] ).toBeLessThan( 0 );
					});
					
					it( "should increase dest", function() {
						expect( results[module.dest] ).toBeGreaterThan( 0 );
					});
				
					it( "should have orig = -dest", function() {
						expect( results[module.orig] + results[module.dest] ).toBe( 0 );
					});
				
					describe( "and with enzym > 0", function() {
						beforeEach( function() {
							substrates[module.name] = 1;
							results = module.step( 0, substrates, 1 );
						});
						
						it( "should have enzym < k * dna ", function() {
							expect( results[module.name] ).toBeLessThan( module.k * substrates[module.dna] );
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
					
					it( "should increase enzym", function() {
						expect( results[module.name] ).toBeGreaterThan( 0 );
					});
					
					it( "should decrease orig", function() {
						expect( results[module.orig] ).toBeLessThan( 0 );
					});
					
					it( "should increase dest", function() {
						expect( results[module.dest] ).toBeGreaterThan( 0 );
					});
				
					it( "should have orig = -dest", function() {
						expect( results[module.orig] + results[module.dest] ).toBe( 0 );
					});
				
					describe( "and with enzym > 0", function() {
						beforeEach( function() {
							substrates[module.name] = 1;
							results = module.step( 0, substrates, 1 );
						});
						
						it( "should have enzym < k * dna ", function() {
							expect( results[module.name] ).toBeLessThan( module.k * substrates[module.dna] );
						});
					});
				});
			});
		});
	});
}); 
