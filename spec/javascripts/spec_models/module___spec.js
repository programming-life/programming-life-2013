describe("Module", function() {
	var module, step;
	
	beforeEach(function() {
		params = { k: 3, b: "5" };
		step = function( t, substrates ) { return { 'a' : this.k + this.b } };
		module = new Model.Module( params, step );
	});

	it("should be able to be created without params or step function", function() {
		module = new Model.Module( null, null );
		expect( module ).toBeDefined();
	});

	it("should be able to set its properties to its params", function() {
		expect( module.k ).toEqual( 3 );
		expect( module.b ).toEqual( 5 );
	});

	it("should be able to access the step function property", function() {
		expect( module._step ).toEqual( step );
	});
	
	it("should be able to run the step property in context", function() {
		expect( module.step( 0, {} ).a ).toEqual( module.k + module.b );
	});

	it("should be able to get the date of creation", function() {
		expect( module.creation ).toBeDefined();
	});
	
	it("should be able to serialize the module", function() {
		serialized = module.serialize( true )
		expect( serialized ).toBeDefined();
		expect( serialized.length ).toBeGreaterThan( 2 )
	});

	it("should be local", function() {
		expect( module.isLocal() ).toBeTruthy();
	});

	it("should be able to get its url", function() {
		expect( module.url ).toBe("/module_instances.json");
	});

	it("should be able to give correct results to ensure tests", function() {
		expect( module._ensure( true, "true" ) ).toBeTruthy();
		expect( module._ensure( false, "false" ) ).toBeFalsy();
	});

	// it("should do nothing when undoing an unchanged module", function() {
	// 	spyOn(module, 'isLocal');
	// //	module.undo();
	// 	expect( module.isLocal ).toHaveBeenCalled();
	// });

	// // it("should do nothing when redoing an unchanged module", function() {

	// // })

	describe( "when serialized and deserialized", function() { 
		var serialized;
		var deserialized;
		
		beforeEach( function() {
			serialized = module.serialize( )
			deserialized = Model.Module.deserialize( serialized );
		});
		
		it("should be able to retain the properties and values", function() {
			expect( deserialized.k ).toEqual( 3 );
			expect( deserialized.b ).toEqual( 5 );
		});

		it("should have retained the step function", function() {
			expect( module._step ).toBeDefined();
			expect( module._step ).toEqual( step );
		});
		
		it("should be able to get the date of creation", function() {
			expect( deserialized.creation ).toBeDefined();
		});
		
		it("should be have same id", function() {
			expect( deserialized.id ).toBeDefined();
			expect( deserialized.id ).toBe( module.id );
		});
	});
	
	describe( "when a property is changed", function() { 
	
		describe( "and it was present", function() {
			var oldNode;
			beforeEach( function() {
				module.k = 8;
				oldNode = module._tree._current;
			});
		
		
			it( "should have applied that change", function() {
				expect( module.k ).toEqual(8)
			});

			it( "should have stored that change", function() {
				expect( module._tree._current._object ).not.toEqual( oldNode );
			});
			
			describe( "and module was serialized and deserialized", function() { 
				var serialized;
				var deserialized;
				
				beforeEach( function() {
					serialized = module.serialize( true )
					deserialized = Model.Module.deserialize( serialized );
				});
				
				it("should have stored the change", function() {
					expect( deserialized.k ).toEqual( 8 );
				});
			});
			
			describe("and undoing that change", function() {
				var undone;			
				beforeEach( function() {
					undone = module._tree._current;
					module.undo();
				});

				it( "should have undone the most recent change", function() {
					expect(module.k).toEqual(3);
				});

				it( "should have updated the most recent change", function() {
					expect( module._tree._current ).toEqual( module._tree._root);
				});

				describe( "and redoing it", function() {
					beforeEach( function() {
						module.redo();
					});

					it( "should have redone the change", function() {
						expect( module.k ).toEqual(8);
					});

					it( "should have updated the most recent change", function() {
						expect( module._tree._current ).toBe( undone )
					});

				});
					
				describe( "and changing it again", function() { 
					beforeEach( function() {
						module.k = 5;
					});
					
					it( "should have updated the most recent change", function() {
						expect( module._tree._current ).not.toBe( undone )
					});

					it( "should have kept the old change in a different branch", function() {
						expect( module._tree._current._parent._children ).toContain( undone )
					});
				});
			});
	
		});
		
		describe( "and it was not present", function() {
		
			beforeEach( function() {
				module.c = 10;
			});
			
			it("should not have applied that change", function() {
				expect(module.c).toEqual(undefined)
			});	

			it( "should not have stored that change", function() {
				expect( module._tree._current._object ).not.toEqual( ["_k",3, 10] );
			});
		});

	});

	describe( "when compounds has been added", function () {
		var aName, aValue;

		beforeEach( function() {
			aName = "a";
			aValue = 2;
			var starts = { };
			starts[ aName ] = aValue
			var params = { "starts": starts }
			module = new Model.Module(params, step);
		});

		it("should be able to set the compounds with values", function() {
			expect( module.getProduct( aName ) ).toEqual( aValue );
		});

		it("should be able to add an additional, new compound", function() {
			module.setCompound( "newone", 14 );
			expect( module.getCompound( "newone" ) ).toEqual( 14 );
		})

		it("should return 0 if the compound doesn't exist", function() {
			expect( module.getCompound( "Obviously not there" ) ).toEqual( 0 );
		})

		it("should be able to handle the aliases", function() {
			module.setProduct( aName, 3 );
			expect( module.getCompound( aName ) ).toEqual( 3 );

			module.setMetabolite( aName, 4 );
			expect( module.getProduct( aName ) ).toEqual( 4 );

			module.setSubstrate( aName, 5 );
			expect( module.getMetabolite( aName ) ).toEqual( 5 );

			module.setCompound( aName, 6 );
			expect( module.getSubstrate( aName ) ).toEqual( 6 );
		});
	});
}); 
