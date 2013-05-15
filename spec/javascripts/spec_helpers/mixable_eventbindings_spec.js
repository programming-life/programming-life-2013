describe("Mixin: Event Bindings", function() {
	
	var mixed;
	var methods = Mixin.EventBindings.InstanceMethods;
	beforeEach( function() {
	
		mixed = _( { } ).extend( methods );
		
	});
	
	describe("when initialized", function() {
	
		beforeEach( function() {
			mixed._allowEventBindings();
			spyOn( Model.EventManager.constructor.prototype, 'bind' );
			spyOn( Model.EventManager.constructor.prototype, 'unbind' );
		});
		
		it( "should have set a private variable", function() {
			expect( mixed._bindings ).toBeDefined();
			expect( Object.keys( mixed._bindings ).length ).toBe( 0 );
		});
		
		describe("and event bound", function() {
		
			var event = 'foo';
			var method = function(){};
			
			beforeEach( function() {
				mixed._bind( event, this, method );
			});
					
			it( "should have bound that event", function() {
				expect( Model.EventManager.constructor.prototype.bind ).toHaveBeenCalled();
				expect( Model.EventManager.constructor.prototype.bind.callCount ).toBe( 1 );
			});
			
			it( "should have saved a binding", function() {
				expect( mixed._bindings ).toBeDefined();
				expect( Object.keys( mixed._bindings ).length ).toBe( 1 );
				expect( mixed._bindings[event].length ).toBe( 1 );
			});
		
			describe("and that event unbound", function() {
		
				var event = 'foo';
				
				beforeEach( function() {
					mixed._unbind( event, this, method );
				});
				
				it( "should have unbound that event", function() {
					expect( Model.EventManager.constructor.prototype.unbind ).toHaveBeenCalled();
					expect( Model.EventManager.constructor.prototype.unbind.callCount ).toBe( 1 );
				});
				
				it( "should have removed that binding", function() {
					expect( mixed._bindings ).toBeDefined();
					expect( Object.keys( mixed._bindings ).length ).toBe( 1 );
					expect( mixed._bindings[event].length ).toBe( 0 );
				});
			});
			
			describe("and another event bound", function() {
			
				var eventb = 'bar';
				var method = function(){};
				
				beforeEach( function() {
					mixed._bind( eventb, this, method );
				});
				
				it( "should have bound that event", function() {
					expect( Model.EventManager.constructor.prototype.bind ).toHaveBeenCalled();
					expect( Model.EventManager.constructor.prototype.bind.callCount ).toBe( 2 );
				});
				
				it( "should have saved a binding", function() {
					expect( mixed._bindings ).toBeDefined();
					expect( Object.keys( mixed._bindings ).length ).toBe( 2 );
					expect( mixed._bindings[eventb].length ).toBe( 1 );
				});
				
				describe("and that event unbound", function() {
			
					beforeEach( function() {
						mixed._unbind( eventb, this, method );
					});
					
					it( "should have unbound that event", function() {
						expect( Model.EventManager.constructor.prototype.unbind ).toHaveBeenCalled();
						expect( Model.EventManager.constructor.prototype.unbind.callCount ).toBe( 1 );
					});
					
					it( "should have removed a binding, but retain the other", function() {
						expect( mixed._bindings ).toBeDefined();
						
						expect( Object.keys( mixed._bindings ).length ).toBe( 2 );
						expect( mixed._bindings[eventb].length ).toBe( 0 );
					});
				
				});
				
				describe("and all event unbound", function() {
			
					beforeEach( function() {
						mixed._unbindAll();
					});
					
					it( "should have unbound those events", function() {
						expect( Model.EventManager.constructor.prototype.unbind ).toHaveBeenCalled();
						expect( Model.EventManager.constructor.prototype.unbind.callCount ).toBe( 2 );
					});
					
					it( "should have removed all bindings", function() {
						expect( mixed._bindings ).toBeDefined();
						expect( Object.keys( mixed._bindings ).length ).toBe( 2 );
						expect( mixed._bindings[event].length ).toBe( 0 );
						expect( mixed._bindings[eventb].length ).toBe( 0 );
					});
				});
			});
		});
	});
});