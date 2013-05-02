describe("Module", function() {
	var module, step;
	
	beforeEach(function() {
		params = { k: 3, b: 5 };
		step = function( t, substrates ) { return { 'a' : this.k + this.b } };
		module = new Model.Module( params, step );
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

	
	describe( "when a property is changed", function() { 
		beforeEach( function() {
			module.k = 8;
		});
		
		it( "should have applied that change", function() {
			expect( module.k ).toEqual(8)
		});

		it( "should have stored that change", function() {
			expect( module._tree._current._object ).toEqual( ["k",3, 8] );
		});
		
		it("should not apply if not present at creation", function() {
			module.c = 10
			expect(module.c).toEqual(undefined)
		});	

		it( "should not have stored that change", function() {
			expect( module._tree._current._object ).toEqual( ["k",3, 8] );
		});

		describe("when having undone the most recent change", function() {
			
			beforeEach( function() {
				module.undo();
			});

			it( "should be able undo the most recent change", function() {
				expect(module.k).toEqual(3);
			});

			it( "should have updated the most recent change", function() {
				expect( module._tree._current ).toEqual( module._tree._root);
			});

			describe( "when redoing that change", function() {
				
				beforeEach( function() {
					module.redo();
				});

				it( "should have redone the change", function() {
					expect( module.k ).toEqual(8);
				});

				it( "should have updated the most recent change", function() {
				});

			});
				
			describe( "when that property is changed again", function() { 
				beforeEach( function() {
					module.k = 5;
				});
				
				it( "should have updated the most recent change", function() {
				});

				it( "should have kept the old change in a different branch", function() {
				});
			});
		});
	});
}); 
