describe("Mixable", function() {
	
	var mixable;
	
	beforeEach(function() {
		mixable = new Helper.Mixable();
	});
	
	it("should have reserved keywords", function() {
		expect( Helper.Mixable.ModuleKeyWords ).toBeDefined();
		expect( Helper.Mixable.ModuleKeyWords ).toMatch( [ 'extended', 'included' ] )
	});
	
	it("should respond to extend", function() {
		expect( Helper.Mixable.extend ).toBeDefined();
	})
	
	it("should respond to extend", function() {
		expect( Helper.Mixable.include ).toBeDefined();
	})
	
	it("should respond to concern", function() {
		expect( Helper.Mixable.concern ).toBeDefined();
	})
	
});