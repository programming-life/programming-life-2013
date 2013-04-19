describe("Cell", function() {
	var cell;
	var module;

	beforeEach(function() {
		cell = new Cell();
	});

	it("should have a creation date", function() {
		expect( cell.creation ).toBeDefined();
	});
  
	describe("when a module has been added", function() {
		beforeEach(function() {
			module = jasmine.createSpy('ModuleStub');
			cell.add( module );
		});

		it("should have that module", function() {
			expect( cell.has( module ) ).toBeTruthy();
		});
		
		it("should be able to remove that module", function() {
			cell.remove( module );
			expect( cell.has( module ) ).toBeFalsy();
		});
	});
	
	describe("when a substance has been added", function() {
		var substance_name = 'mock';
		var substance_amount = 42;
		
		beforeEach(function() {
			cell.add_substance( substance_name, substance_amount );
		});
		
		it("should have that substance", function() {
			expect( cell.amount_of( substance_name ) ).toBe( substance_amount );
		});
		
		it("should be able to remove that substance", function() {
			cell.remove_substance( substance_name );
			expect( cell.amount_of( substance_name ) ).not.toBeDefined();
		});
	});
	
	describe("when the cell has ran", function() {
		var run_t = 13;
		var run_dt = 5;
		
		beforeEach(function() {
			spyOn( cell, 'step' );
			module = jasmine.createSpy('ModuleStub');
			cell.add( module );
			cell.run( run_dt, run_t );
		});
		
		it("should have a fixed time run with dt steps", function() {
			
			expect( cell.step ).toHaveBeenCalledWith( run_dt );
			expect( cell.step.callCount).toBe( ( run_t - ( run_t % run_dt ) ) / run_dt );
			
		});
	});
	
});