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
		var run_t = 10;
		var result = null;
		
		beforeEach(function() {
			result = cell.run( run_t );
		});
		
		it("should have run with t runtime", function() {
			
			expect( result ).toBeDefined();
			expect( result.x ).toBeDefined();
			expect( result.x[ 0 ] ).toBe( 0 );
			expect( result.x[ result.x.length - 1 ] ).toBe( run_t );
			
		});
	});
	
});