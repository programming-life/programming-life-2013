describe("Base", function() {
	var controller, view;
	var dummy = function() {};
	dummy.prototype.kill = jasmine.createSpy( 'kill' );
	
	beforeEach( function() {
		view = new dummy();
		controller = new Controller.Base( view );
		spyOn( controller, 'kill' ).andCallThrough();
	});
	
	describe("when initialized", function() {
	
		it("should contain the view", function() {
			expect( controller.view ).toBe( view );
		});
		
		it("should have no children", function() {
			expect( controller.controllers() ).toMatch( {} );
		});
		
	});
	
	describe("when child is added", function() {
	
		var child = new dummy();
		beforeEach( function() {
			controller.addChild( 'dummy', child );
		});
	
		it("should contain the child", function() {
			expect( controller.controller('dummy') ).toBe( child );
		});
		
		describe("when child is removed", function() {
	
			beforeEach( function() {
				controller.removeChild( 'dummy' );
			});
		
			it("should not contain the child", function() {
				expect( controller.controller('dummy') ).not.toBeDefined( );
			});
			
			it("should have killed the child", function() {
				expect( child.kill.callCount ).toBeGreaterThan( 0 );
			});
		});
		
	});
	
	describe("when killed", function() {
	
		var child = new dummy();
		beforeEach( function() {
			controller.kill();
		});
	
		it("should have killed the controller", function() {
			expect( controller.kill.callCount ).toBeGreaterThan( 0 );
		});
		
		it("should have killed the view", function() {
			expect( controller.view.kill.callCount ).toBeGreaterThan( 0 );
		});
		
	});

	afterEach( function() {
		controller.kill()
	});

});
