describe("Module Transporter", function() {
	
	describe( "when using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter();
		});
		
		it( "should have 'transporter_undefined_to_undefined' as name", function() {
			expect( module.name ).toBe( "transporter_undefined_to_undefined" );
		});
		
		it( "should have 'undefined' as orig", function() {
			expect( module.orig ).toBe( undefined );
		});
		
		it( "should have 'undefined' as dest", function() {
			expect( module.dest ).toBe( undefined );
		});
		
		it( "should have 's_int' as consume", function() {
			expect( module.consume ).toBe( 's_int' );
		});
		
		it( "should have 1 as k (transcription value)", function() {
			expect( module.k ).toBe( 1 );
		});
		
		it( "should have 1 as k_tr (transport value)", function() {
			expect( module.k_tr ).toBe( 1 );
		});
		
		it( "should have 1 as k_m (reaction value)", function() {
			expect( module.k_m ).toBe( 1 );
		});
		
		it( "should have 'dna' as dna", function() {
			expect( module.dna ).toBe( "dna" );
		});
		
		it( "should have 'cell' as cell", function() {
			expect( module.cell ).toBe( "cell" );
		});
		
		it( "should have a property direction", function() {
			expect( module.direction ).toBe( 0 );
		});
		
		it( "should have 2 substrate: name with value 1, dest with 0", function() {
			expect( _(module.starts).size() ).toBe( 2 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
			expect( module.amount ).toBe( 1 );
			expect( module.starts.dest ).toBeDefined();
			expect( module.starts.dest ).toBe( 0 );
		});
		
	});
			
	describe( "when using params in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter( { a: 'new', dna: 'override_dna' } );
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
				module = new Model.Transporter( { a: 'new' }, undefined, "food" );
			});
			
			it( "should override default parameters", function() {
				expect( module.orig ).toMatch( 'food' );
			});
			
		});
		
		describe( "and using named option in the constructor, also as params", function() {
			
			beforeEach( function() {
				module = new Model.Transporter( { a: 'new', orig: 'winner' }, undefined, "loser" );
			});
			
			it( "should not override given params ", function() {
				expect( module.orig ).toMatch( 'winner' );
			});
			
		});
	});
	
	describe( "when using start in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter( undefined, 2 );
		});		
		
		it( "should overide the default start value", function() {
			expect( module.starts.name ).toBe( 2 );
			expect( module.amount ).toBe( 2 );
		});
	});
	
	describe( "when using orig in the constructor", function() {
		
		var module;
		var tname = "transporter_magix_to_undefined";
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, 'magix' );
		});		
		
		it( "should overide the default orig with 'magix'", function() {
			expect( module.orig ).toMatch( 'magix' );
		});
		
		it( "should overide the default name with '" + tname + "'", function() {
			expect( module.name ).toMatch( tname );
		});
	});
	
	describe( "when using dest in the constructor", function() {
		
		var module;
		var tname = "transporter_undefined_to_magix";
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, undefined, 'magix' );
		});		
		
		it( "should overide the default dest with 'magix'", function() {
			expect( module.dest ).toMatch( 'magix' );
		});
		
		it( "should overide the default name with '" + tname + "'", function() {
			expect( module.name ).toMatch( tname );
		});
	});
		
	
	describe( "when using name in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, undefined, undefined, 'special_name' );
		});		
		
		it( "should overide the name with that name", function() {
			expect( module.name ).toMatch( 'special_name' );
		});
	});
	
	describe( "when using dir in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, undefined, undefined, undefined, 1 );
		});		
		
		it( "should overide the direction with that value", function() {
			expect( module.direction ).toMatch( 1 );
		});
	});
	
	describe( "when using food in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, undefined, undefined, undefined, undefined, 'special_name' );
		});		
		
		it( "should overide the consume with that value", function() {
			expect( module.consume ).toMatch( 'special_name' );
		});
	});
	
	describe( "when stepping", function() {
		
		var module, results;
		var substrates;
		
		beforeEach( function() { 
			substrates = {};
			module = new Model.Transporter( { }, undefined, 'a', 'b' );
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
				substrates[module.consume] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna and food substrate", function() {
		
			beforeEach( function() {
				substrates[module.dna] = 1;
				substrates[module.consume] = 1;
			});
			
			describe( "with growth_rate > 0", function() {
			
				beforeEach( function() {
					results = module.step( 0, substrates, 1 );
				});
				
				it( "should have results", function() {
					expect( _(results).isEmpty() ).toBeFalsy();
				});
			
				it( "should increase name", function() {
					expect( results[module.name] ).toBeGreaterThan( 0 );
			    })
				
				describe( "and name > 0", function() {
					beforeEach( function() {
						substrates[module.name] = 1;
						results = module.step( 0, substrates, 1 );
					})
				
					it( "should increase name less", function() {
						expect( results[module.name] ).toBeLessThan( 1 );
					})
				});
			});
			
			describe( "with growth_rate = 0", function() {
			
				beforeEach( function() {
					results = module.step( 0, substrates, 0 );
				});
			
				it( "should have results", function() {
					expect( _(results).isEmpty() ).toBeFalsy();
				});
				
				it( "should increase name", function() {
					expect( results[module.name] ).toBeGreaterThan( 0 );
				});
				
				describe( "and protein > 0", function() {
					it( "should increase name exactly by v", function() {
						expect( results[module.name] ).toBe( 1 );
					});
				
				});
			});
			
		});
		
		describe( "with name", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with orig substrate", function() {
			
			beforeEach( function() { 
				substrates[module.orig] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with name and orig substrate", function() {
		
			beforeEach( function() {
				substrates[module.name] = 1;
				substrates[module.orig] = 1;
			});
			
			describe( "and is transport into cell", function() {
			
				beforeEach( function() {
					module.direction = 1;
				});
				
				describe( "and cell = 1", function() {
					beforeEach( function() {
						substrates[module.cell] = 1;
						results = module.step( 0, substrates, 1 );
					});
				
					it( "should have results", function() {
						expect( _(results).isEmpty() ).toBeFalsy();
					});
				
					it( "should increase dest", function() {
						expect( results[module.dest] ).toBeGreaterThan( 0 );
					})
					
					it( "should decrease orig with orig = -dest", function() {
						expect( results[module.dest] + results[module.orig] ).toBe( 0 );
					});
				});
				
				describe( "and cell > 1", function() {
			
					beforeEach( function() {
						substrates[module.cell] = 2;
						results = module.step( 0, substrates, 1 );
					});
				
					it( "should have results", function() {
						expect( _(results).isEmpty() ).toBeFalsy();
					});
				
					it( "should decrease orig more than dest increase", function() {
						expect(  results[module.dest] + results[module.orig] ).toBeLessThan( 0 );
					});
				});
			});
			
			
			
			describe( "and is transport out of cell", function() {
			
				beforeEach( function() {
					module.direction = -1;
				});
				
				describe( "and cell = 1", function() {
					beforeEach( function() {
						substrates[module.cell] = 1;
						results = module.step( 0, substrates, 1 );
					});
				
					it( "should have results", function() {
						expect( _(results).isEmpty() ).toBeFalsy();
					});
				
					it( "should increase dest", function() {
						expect( results[module.dest] ).toBeGreaterThan( 0 );
					})
					
					it( "should decrease orig with orig = -dest", function() {
						expect( results[module.dest] + results[module.orig] ).toBe( 0 );
					});
				});
				
				describe( "and cell > 1", function() {
			
					beforeEach( function() {
						substrates[module.cell] = 2;
						results = module.step( 0, substrates, 1 );
					});
				
					it( "should have results", function() {
						expect( _(results).isEmpty() ).toBeFalsy();
					});
				
					it( "should decrease orig with orig = -dest", function() {
						expect( results[module.dest] + results[module.orig] ).toBe( 0 );
					});
				});
			});
			
		});
	});
		
	describe( "when using generator int helper function", function() {
		
		describe( "and defaults", function() {
			var module;
			beforeEach( function() {
				module = new Model.Transporter.int();
			});
			
			it( "should have 2 substrate: name with value 1, dest with 0", function() {
				expect( _(module.starts).size() ).toBe( 2 );
				expect( module.starts.name ).toBeDefined();
				expect( module.starts.name ).toBe( 1 );
				expect( module.amount ).toBe( 1 );
				expect( module.starts.dest ).toBeDefined();
				expect( module.starts.dest ).toBe( 0 );
			});
			
			it( "should have 's_ext' as orig", function() {
				expect( module.orig ).toBe( "s_ext" );
			});
			
			it( "should have 's_int' as dest", function() {
				expect( module.dest ).toBe( "s_int" );
			});
			
			it( "should have 1 as direction", function() {
				expect( module.direction ).toBe( 1 );
			});
			
			it( "should have 'transporter_s_in' as name", function() {
				expect( module.name ).toBe( 'transporter_s_in' );
			});
		
		});
		
		describe( "and parameters set", function() {
			var module;
			beforeEach( function() {
				module = new Model.Transporter.int(
					{ 'a' : 1 }, 0, 'f', '_a', '_b' 
				);
			});
			
			it( "should have 2 substrate: name with value set, dest with 0", function() {
				expect( _(module.starts).size() ).toBe( 2 );
				expect( module.starts.name ).toBeDefined();
				expect( module.starts.name ).toBe( 0 );
				expect( module.amount ).toBe( 0 );
				expect( module.starts.dest ).toBeDefined();
				expect( module.starts.dest ).toBe( 0 );
			});
			
			it( "should have '#{substrate}_#{orig_post}' as orig", function() {
				expect( module.orig ).toBe( "f_a" );
			});
			
			it( "should have '#{substrate}_#{dest_post}' as dest", function() {
				expect( module.dest ).toBe( "f_b" );
			});
			
			it( "should have 1 as direction", function() {
				expect( module.direction ).toBe( 1 );
			});
			
			it( "should have 'transporter_#{substrate}_in' as name", function() {
				expect( module.name ).toBe( 'transporter_f_in' );
			});
		});
	});
	
	describe( "when using generator ext helper function", function() {
		
		describe( "and defaults", function() {
			var module;
			beforeEach( function() {
				module = new Model.Transporter.ext();
			});
			
			it( "should have 2 substrate: name with value 0, dest with 0", function() {
				expect( _(module.starts).size() ).toBe( 2 );
				expect( module.starts.name ).toBeDefined();
				expect( module.starts.name ).toBe( 0 );
				expect( module.amount ).toBe( 0 );
				expect( module.starts.dest ).toBeDefined();
				expect( module.starts.dest ).toBe( 0 );
			});
			
			it( "should have 'p_int' as orig", function() {
				expect( module.orig ).toBe( "p_int" );
			});
			
			it( "should have 'p_ext' as dest", function() {
				expect( module.dest ).toBe( "p_ext" );
			});
			
			it( "should have -1 as direction", function() {
				expect( module.direction ).toBe( -1 );
			});
			
			it( "should have 'transporter_p_out' as name", function() {
				expect( module.name ).toBe( 'transporter_p_out' );
			});
			
		});
		
		describe( "and parameters set", function() {
			var module;
			beforeEach( function() {
				module = new Model.Transporter.ext(
					{ 'a' : 1 }, 1, 'f', '_b', '_a' 
				);
			});
			
			it( "should have 2 substrate: name with value set, dest with 0", function() {
				expect( _(module.starts).size() ).toBe( 2 );
				expect( module.starts.name ).toBeDefined();
				expect( module.starts.name ).toBe( 1 );
				expect( module.amount ).toBe( 1 );
				expect( module.starts.dest ).toBeDefined();
				expect( module.starts.dest ).toBe( 0 );
			});
			
			it( "should have '#{substrate}_#{orig_post}' as orig", function() {
				expect( module.orig ).toBe( "f_b" );
			});
			
			it( "should have '#{substrate}_#{dest_post}' as dest", function() {
				expect( module.dest ).toBe( "f_a" );
			});
			
			it( "should have -1 as direction", function() {
				expect( module.direction ).toBe( -1 );
			});
			
			it( "should have 'transporter_#{substrate}_out' as name", function() {
				expect( module.name ).toBe( 'transporter_f_out' );
			});
		});
	});
	
	
}); 
