describe("Cell", function() {
	var cell;
	var module;

	beforeEach(function() {
		cell = new Cell();
	});

	it("should have a creation date", function() {
		expect(cell.creation).toBeDefined();
	});
  
	describe("when a module has been added", function() {
		beforeEach(function() {
			module = jasmine.createSpy('ModuleStub');
			cell.add( module );
		});

		it("should have that module", function() {
			expect(cell.has( module )).toBeTruthy();
		});
		
		it("should be able to remove that module", function() {
			cell.remove( module );
			expect(cell.has( module )).toBeFalsy();
		});
	});
	
});