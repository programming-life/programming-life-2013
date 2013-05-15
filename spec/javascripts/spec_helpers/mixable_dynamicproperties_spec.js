
describe("Mixin: Dynamic Properties", function() {
	
	var mixed;
	var methods = Mixin.DynamicProperties.InstanceMethods;
	beforeEach( function() {
		mixed = _( { } ).extend( methods );
	});
	
	describe("when properties from parameters are created", function() {
	
		beforeEach( function() {
			spyOn( Model.EventManager.constructor.prototype, 'trigger' )
			mixed._propertiesFromParams({ foo: 'bar', baz: '2' });
		});
		
		it( "should have set a private variable", function() {
			expect( mixed._dynamicProperties ).toBeDefined();
		});
		
		it( "should have set a private variable for each param", function() {
			expect( mixed._foo ).toBeDefined();
			expect( mixed._baz ).toBeDefined();
		});
		
		it( "should have saved the values and parsed numbers", function() {
			expect( mixed._foo ).toBe( 'bar' );
			expect( mixed._baz ).toBe( 2 );
		});
		
		it( "should have created getters and setters", function() {
			expect( mixed.foo ).toBe( 'bar' );
			expect( mixed.baz ).toBe( 2 );
			
			mixed.foo = 'foo';
			mixed.baz = 3;
			expect( mixed.foo ).toBe( 'foo' );
			expect( mixed.baz ).toBe( 3 );
			
			expect( mixed._foo ).toBe( 'foo' );
			expect( mixed._baz ).toBe( 3 );
		});
		
		it( "should have pushed to the private variable", function() {
			expect( mixed._dynamicProperties ).toMatch( [ 'foo', 'baz' ] );
		})
		
		xit( "should have called the event", function() {
			expect( Model.EventManager.constructor.prototype.trigger ).toHaveBeenCalled(); // doesn't work because of singleton
		});
		
	});
	
	describe("when a non enumerable value is attached", function() {
	
		beforeEach( function() {
			mixed._nonEnumerableValue( 'foo', 'bar' );
		});
		
		it( "should have created a property with a value", function() {
			expect( mixed.foo ).toBeDefined(); 
			expect( mixed.foo ).toBe( 'bar' );
		});
		
		it( "should not be configurable", function() {
			desc = Object.getOwnPropertyDescriptor( mixed, 'foo' );
			expect( desc.configurable ).toBeFalsy();
		});
		
		it( "should not be enumerable", function() {
			desc = Object.getOwnPropertyDescriptor( mixed, 'foo' );
			expect( desc.enumerable ).toBeFalsy();
		});
		
		it( "should be writable", function() {
			desc = Object.getOwnPropertyDescriptor( mixed, 'foo' );
			expect( desc.writable ).toBeTruthy();
		});
	});
	
	describe("when a non enumerable getter is attached", function() {
	
		var func = function() { return 'bar' }; 
		beforeEach( function() {
			mixed._nonEnumerableGetter( 'foo', func );
		});
		
		it( "should have created a property with a getter", function() {
			expect( mixed.foo ).toBeDefined(); 
			expect( mixed.foo ).toBe( 'bar' );
		});
		
		it( "should not be configurable", function() {
			desc = Object.getOwnPropertyDescriptor( mixed, 'foo' );
			expect( desc.configurable ).toBeFalsy();
		});
		
		it( "should not be enumerable", function() {
			desc = Object.getOwnPropertyDescriptor( mixed, 'foo' );
			expect( desc.enumerable ).toBeFalsy();
		});
		
		it( "should not have a setter", function() {
			mixed.foo = 2
			expect( mixed.foo ).toBe( 'bar' );
		});
	});
	
});