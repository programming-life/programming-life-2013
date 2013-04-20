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
	
	describe("when a substrate has been added", function() {
		var substrate_name = 'mock';
		var substrate_amount = 42;
		
		beforeEach(function() {
			cell.add_substrate( substrate_name, substrate_amount );
		});
		
		it("should have that substrate", function() {
			expect( cell.amount_of( substrate_name ) ).toBe( substrate_amount );
		});
		
		it("should be able to remove that substrate", function() {
			cell.remove_substrate( substrate_name );
			expect( cell.amount_of( substrate_name ) ).not.toBeDefined();
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