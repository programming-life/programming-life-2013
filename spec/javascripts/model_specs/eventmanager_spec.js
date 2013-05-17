describe("Event Manager", function() {

	describe("when event bound", function() {
		
		var event = 'foo';
		var method = jasmine.createSpy( 'method' );
		var previousCount;
		
		beforeEach( function() {
			Model.EventManager.clear();
			
			previousCount =  Model.EventManager.bindings( event ).length;
			Model.EventManager.bind( event, this, method );
		});
				
		it( "should have saved a binding", function() {
			expect( Model.EventManager.bindings( event ) ).toBeDefined();
			expect( Model.EventManager.bindings( event ).length - previousCount ).toBe( 1 );
		});
		
		describe("and triggered", function() {
			
			var caller = { a: 1 };
			var arg = 'zimbabwe';
			
			beforeEach( function() {
				previousCount = method.callCount;
				Model.EventManager.trigger( event, caller, [ arg ] );
			});
			
			it( "should have triggered the event", function() {
				expect( method ).toHaveBeenCalledWith( caller, arg )
			});
			
			it( "should have called it xxx", function() {
				expect( method.callCount - previousCount ).toBe( Model.EventManager.bindings( event ).length );
			});
			
		});
	
		describe("and that event unbound", function() {
	
			var caller = { a: 1 };
			var event = 'foo';
			
			beforeEach( function() {
				previousCount =  Model.EventManager.bindings( event ).length;
				Model.EventManager.unbind( event, this, method );
			});
			
			it( "should have removed that binding", function() {
				expect( Model.EventManager.bindings( event ) ).toBeDefined();
				expect( previousCount - Model.EventManager.bindings( event ).length ).toBe( 1 );
				
			});
		});
		
		describe("and another event bound", function() {
		
			var eventb = 'bar';
			var method = function(){};
			
			beforeEach( function() {
				previousCount =  Model.EventManager.bindings( eventb ).length;
				Model.EventManager.bind( eventb, this, method );
			});

			it( "should have saved a binding", function() {
				expect( Model.EventManager.bindings( eventb ) ).toBeDefined();
				expect( Model.EventManager.bindings( eventb ).length - previousCount ).toBe( 1 );
			});
			
			describe("and that event unbound", function() {
	
				var previousCount2;
				
				beforeEach( function() {
					previousCount =  Model.EventManager.bindings( eventb ).length;
					previousCount2 =  Model.EventManager.bindings( event ).length;
					Model.EventManager.unbind( eventb, this, method );
				});

				it( "should have removed a binding, but retain the other", function() {
					expect( Model.EventManager.bindings( event ) ).toBeDefined();
					expect( previousCount2 - Model.EventManager.bindings( event ).length ).toBe( 0 );
					expect( Model.EventManager.bindings( eventb ) ).toBeDefined();
					expect( previousCount - Model.EventManager.bindings( eventb ).length ).toBe( 1 );
				});
				
			});

		});
	});
	
	describe( "when event bound through on", function() {
	
		var event = 'foo';
		var method = function(){};
		
		beforeEach( function() {
			Model.EventManager.clear();
			spyOn( Model.EventManager.constructor.prototype, 'bind' );
			Model.EventManager.on( event, this, method );
		});
		
		it( "should have bound that event", function() {
			expect( Model.EventManager.constructor.prototype.bind ).toHaveBeenCalledWith( event, this, method );
			expect( Model.EventManager.constructor.prototype.bind.callCount ).toBe( 1 );
		});
	});
		
	describe( "when event unbound through off", function() {
			
		var event = 'foo';
		var method = function(){};
		
		beforeEach( function() {
			Model.EventManager.clear();
			spyOn( Model.EventManager.constructor.prototype, 'unbind' );
			Model.EventManager.off( event, this, method );
		});
		
		it( "should have unbound that event", function() {
			expect( Model.EventManager.constructor.prototype.unbind ).toHaveBeenCalledWith( event, this, method );
			expect( Model.EventManager.constructor.prototype.unbind.callCount ).toBe( 1 );
		});		
	});
});