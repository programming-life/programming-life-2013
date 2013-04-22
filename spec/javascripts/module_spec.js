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
	
	describe( "when a property is changed", function() { 
		beforeEach( function() {
			module.k = 8;
		});
		
		it( "should have stored that change", function() {
			expect( module.k ).toEqual(8)
		});
		
		it("should not store if not present at creation", function() {
			module.c = 10
			expect(module.c).toEqual(undefined)
		});	
		
		it( "should be able undo that change", function() {
			module.popHistory();
			expect(module.k).toEqual(3);
		});
		
		describe( "and when that change is undone", function() { 
			beforeEach( function() {
				module.popHistory();
			});
		
			it( "should be able redo that change", function() {
				module.popFuture();
				expect( module.k ).toEqual(8);
			});
			
			describe( "and when that property is changed again", function() { 
				beforeEach( function() {
					module.k = 5;
				});
				
				it( "should clear all redo moves", function() {
					module.popFuture();
					expect( module.k ).toEqual(5)
				});
			});
		});

	});
}); 
