describe("Module Transporter", function() {
	
	describe( "when using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter();
		});
		
		it( "should have 'transporter_undefined' as name", function() {
			expect( module.name ).toBe( "transporter_undefined" );
		});
		
		it( "should have 'undefined#ext' as orig", function() {
			expect( module.orig ).toBe( "undefined#ext" );
		});
		
		it( "should have 'undefined#tint' as dest", function() {
			expect( module.dest ).toBe( "undefined#int" );
		});
		
		it( "should have 's#int' as consume", function() {
			expect( module.consume ).toMatch( ['s#int'] );
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
		
		it( "should have a property direction inward", function() {
			expect( module.direction ).toBe( Model.Transporter.Inward );
		});
		
		it( "should have a property type active", function() {
			expect( module.type ).toBe( Model.Transporter.Active );
		});
		
		it( "should have 2 substrate: name with value 1, dest with 0", function() {
			expect( _(module.starts).size() ).toBe( 2 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
			expect( module.amount ).toBe( 1 );
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
				deserialized = Model.Transporter.deserialize( serialized )
				expect( deserialized ).toBeDefined();
				expect( deserialized.constructor.name ).toBe( module.constructor.name )
			});
			
			describe("and when deserialized", function() {
				var deserialized;
				beforeEach( function() {
					deserialized = Model.Transporter.deserialize( serialized )
				});
				
				it( "should have 'transporter_undefined' as name", function() {
					expect( module.name ).toBe( "transporter_undefined" );
				});
				
				it( "should have 'undefined#ext' as orig", function() {
					expect( module.orig ).toBe( "undefined#ext" );
				});
				
				it( "should have 'undefined#tint' as dest", function() {
					expect( module.dest ).toBe( "undefined#int" );
				});
				
				it( "should have 's#int' as consume", function() {
					expect( module.consume ).toMatch( ['s#int'] );
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

				it( "should have a property direction inward", function() {
					expect( module.direction ).toBe( Model.Transporter.Inward );
				});
				
				it( "should have a property type active", function() {
					expect( module.type ).toBe( Model.Transporter.Active );
				});

				it( "should have 2 substrate: name with value 1, dest with 0", function() {
					expect( _(module.starts).size() ).toBe( 2 );
					expect( module.starts.name ).toBeDefined();
					expect( module.starts.name ).toBe( 1 );
					expect( module.amount ).toBe( 1 );
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
				expect( module.orig ).toMatch( 'food#ext' );
				expect( module.dest ).toMatch( 'food#int' );
			});
			
		});
		
		describe( "and using named option in the constructor, also as params", function() {
			
			beforeEach( function() {
				module = new Model.Transporter( { a: 'new', transported: 'winner' }, undefined, "loser" );
			});
			
			it( "should not override given params ", function() {
				expect( module.orig ).toMatch( 'winner#ext' );
				expect( module.dest ).toMatch( 'winner#int' );
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
	
	describe( "when using transported in the constructor", function() {
		
		var module;
		var tname = "transporter_magix";
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, 'magix' );
		});		
		
		it( "should overide the default transported with 'magix'", function() {
			expect( module.orig ).toMatch( 'magix#ext' );
			expect( module.dest ).toMatch( 'magix#int' );
		});
		
		it( "should overide the default name with '" + tname + "'", function() {
			expect( module.name ).toMatch( tname );
		});
	});
	
	
	describe( "when using name in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, undefined, 'special_name' );
		});		
		
		it( "should overide the name with that name", function() {
			expect( module.name ).toMatch( 'special_name' );
		});
	});
	
	describe( "when using dir in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, undefined, undefined, Model.Transporter.Outward );
		});		
		
		it( "should overide the direction with that value", function() {
			expect( module.direction ).toMatch( Model.Transporter.Outward );
		});
	});
	
	describe( "when using type in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, undefined, undefined, undefined, Model.Transporter.Passive );
		});		
		
		it( "should overide the consume with that value", function() {
			expect( module.type ).toBe( Model.Transporter.Passive );
		});
	});
	
	describe( "when using consume in the constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.Transporter( undefined, undefined, undefined, undefined, undefined, undefined, 'special_name' );
		});		
		
		it( "should overide the consume with that value", function() {
			expect( module.consume ).toMatch( ['special_name'] );
		});
	});
	
	describe( "when stepping", function() {
		
		var module, results;
		var substrates;
		
		beforeEach( function() { 
			substrates = {};
			module = new Model.Transporter( { }, undefined, 'a' );
		});
		
		describe( "with no substrates", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 0;
				substrates[module.orig] = 0;
				substrates[module.dest] = 0;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna substrate", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 0;
				substrates[module.orig] = 0;
				substrates[module.dest] = 0;
				substrates[module.dna] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with food substrate", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 0;
				substrates[module.orig] = 0;
				substrates[module.dest] = 0;
				substrates[module.consume[0]] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with dna and food substrate", function() {
		
			beforeEach( function() {
				substrates[module.name] = 0;
				substrates[module.orig] = 0;
				substrates[module.dest] = 0;
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
				substrates[module.orig] = 0;
				substrates[module.dest] = 0;
			
				substrates[module.name] = 1;
				results = module.step( 0, substrates, 0 );
			});
			
			it( "should not have results", function() {
				expect( _(results).isEmpty() ).toBeTruthy();
			});
		});
		
		describe( "with orig substrate", function() {
			
			beforeEach( function() { 
				substrates[module.name] = 0;
				substrates[module.dest] = 0;
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
				substrates[module.dest] = 0;
			});
			
			describe( "and is transport into cell (active)", function() {
			
				beforeEach( function() {
					module.direction = Model.Transporter.Inward;
					module.type = Model.Transporter.Active;
					substrates[module.orig] = 1;
					substrates[module.dest] = 0;
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
						expect(  -results[module.orig] - results[module.dest]  ).toBeGreaterThan( 0 );
					});
				});
			});
			
			
			describe( "and is transport out of cell (passive)", function() {
			
				beforeEach( function() {
					module.direction = Model.Transporter.Outward
					module.type = Model.Transporter.Passive
					substrates[module.orig] = 1;
					substrates[module.dest] = 0;
				});
				
				describe( "and cell = 1", function() {
					beforeEach( function() {
						substrates[module.cell] = 2;
						results = module.step( 0, substrates, 1 );
					});
				
					it( "should have results", function() {
						expect( _(results).isEmpty() ).toBeFalsy();
					});
				
					it( "should increase dest", function() {
						expect( results[module.dest] ).toBeGreaterThan( 0 );
					})
					
					it( "should decrease orig less than dest increase", function() {
						expect( results[module.dest] + results[module.orig] ).toBeGreaterThan( 0 );
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
				
					it( "should decrease orig less than dest increase", function() {
						expect( results[module.dest] + results[module.orig] ).toBeGreaterThan( 0 );
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
			
			it( "should have 's#ext' as orig", function() {
				expect( module.orig ).toBe( "s#ext" );
			});
			
			it( "should have 's#int' as dest", function() {
				expect( module.dest ).toBe( "s#int" );
			});
			
			it( "should have Inward as direction", function() {
				expect( module.direction ).toBe( Model.Transporter.Inward );
			});
			
			it( "should have 'transporter_s_in' as name", function() {
				expect( module.name ).toBe( 'transporter_s_in' );
			});
		
		});
		
		describe( "and parameters set", function() {
			var module;
			beforeEach( function() {
				module = new Model.Transporter.int(
					{ 'a' : 1 }, 0, 'f'
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
			
			it( "should have '#{substrate}#ext' as orig", function() {
				expect( module.orig ).toBe( "f#ext" );
			});
			
			it( "should have '#{substrate}#int' as dest", function() {
				expect( module.dest ).toBe( "f#int" );
			});
			
			it( "should have Inward as direction", function() {
				expect( module.direction ).toBe( Model.Transporter.Inward );
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
			
			it( "should have 'p#int' as orig", function() {
				expect( module.orig ).toBe( "p#int" );
			});
			
			it( "should have 'p#ext' as dest", function() {
				expect( module.dest ).toBe( "p#ext" );
			});
			
			it( "should have Outward as direction", function() {
				expect( module.direction ).toBe( Model.Transporter.Outward );
			});
			
			it( "should have 'transporter_p_out' as name", function() {
				expect( module.name ).toBe( 'transporter_p_out' );
			});
			
		});
		
		describe( "and parameters set", function() {
			var module;
			beforeEach( function() {
				module = new Model.Transporter.ext(
					{ 'a' : 1 }, 1, 'f'
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
			
			it( "should have '#{substrate}#int' as orig", function() {
				expect( module.orig ).toBe( "f#int" );
			});
			
			it( "should have '#{substrate}#ext' as dest", function() {
				expect( module.dest ).toBe( "f#ext" );
			});
			
			it( "should have Outward as direction", function() {
				expect( module.direction ).toBe( Model.Transporter.Outward );
			});
			
			it( "should have 'transporter_#{substrate}_out' as name", function() {
				expect( module.name ).toBe( 'transporter_f_out' );
			});
		});
	});
	
	
}); 
