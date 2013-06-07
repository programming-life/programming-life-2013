describe("Numeric", function() {

	describe("when ran", function() {
		
		var t = 2;
		var maxit = 5;
		var progress = 0;
		var p = 0;
		
		beforeEach( function() {
			token = numeric.asynccancel();
			step = function( y ) {
				return 42;
			}
			
			promise = numeric.asyncdopri( 0, t, 0, step, undefined, maxit, undefined, token );
			promise.always( function( r ) { results = r } );
			promise.progress( function( value ) { p++; progress = value; } );
			waitsFor( function() {
				return promise.state() === "rejected" || promise.state() === "resolved" 
			} );
		});
		
		it("should have resolved", function() {
			runs( function() {
				expect(  promise.state()  ).toMatch( "resolved" ); 
			});
		});
		
		
		it("should not have message", function() {
			runs( function() {
				expect( results.msg ).not.toBeDefined();
			});
		});
		
		it("should have run at max for iterations", function() {
			runs( function() {
				expect( results.iterations ).not.toBeGreaterThan( maxit );
			});
		});
		
		it("should have had progress", function() {
			runs( function() {
				expect( p ).not.toBeLessThan( results.iterations );
			});
		});
		
		it("should have finished progress", function() {
			runs( function() {
				expect( progress ).toBe( 1 );
			});
		});
		
		it("should have ran for t", function() {
			runs( function() {
				expect( results.x[ 0 ] ).toBe( 0 )
				expect( results.x[ results.x.length - 1 ] ).toBe( t );
			});
		});
		
		it("should calculated the correct answer ", function() {
			runs( function() {
				expect( results.y[ 0 ] ).toBe( 0 )
				expect( results.y[ results.y.length - 1 ] ).toBe( 42 * t );
			});
		});
	
	});
	
	describe("when cancelled", function() {
		
		var t = 2;
		var maxit = 5;
		var progress = 0;
		var p = 0;
		
		beforeEach( function() {
			token = numeric.asynccancel();
			step = function( y ) {
				return 42;
			}
			
			token.cancel()
			promise = numeric.asyncdopri( 0, t, 0, step, undefined, maxit, undefined, token )
			promise.always( function( r ) { results = r; } );
			promise.progress( function( value ) { p++; progress = value; } );
			waitsFor( function() {
				return promise.state() === "rejected" || promise.state() === "resolved" 
			} );
		});
		
		it("should have rejected", function() {
			runs( function() {
				expect(  promise.state()  ).toMatch( "rejected" ) ;
			});
		});
		
		
		it("should have cancelled messages", function() {
			runs( function() {
				expect( results.msg ).toMatch( 'cancelled' );
			});
		});
		
		it("should have run at max for iterations", function() {
			runs( function() {
				expect( results.iterations ).not.toBeGreaterThan( maxit );
			});
		});
		
		it("should not have finished progress", function() {
			runs( function() {
				expect( progress ).not.toBe( 1 ) ;
			});
		});
		
		it("should have ran for less than t", function() {
			runs( function() {
				expect( results.x[ 0 ] ).toBe( 0 )
				expect( results.x[ results.x.length - 1 ] ).toBeLessThan( t );
			});
		});
		
		it("should not have calculated the correct answer ", function() {
			runs( function() {
				expect( results.y[ 0 ] ).toBe( 0 )
				expect( results.y[ results.y.length - 1 ] ).not.toBe( 42 * t );
			});
		});
	
	});
});