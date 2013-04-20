describe("Module", function() {
	var module;
	
	beforeEach(function() {
		params = {k: 3, b: 5}
		module = new Module(params)
	});

	it("should be able to set its properties to its params", function() {
		expect(module.k).toEqual(3);
		expect(module.b).toEqual(5);
	});

	it("should be able to alter its stored properties", function() {
		module.k = 8
		expect(module.k).toEqual(8)
	});

	it("should be able undo and redo its property changes", function() {
		module.k = 8
		expect(module.k).toEqual(8)
		module.popHistory()
		expect(module.k).toEqual(3)
		module.popFuture()
		expect(module.k).toEqual(8)
	});

	it("it should clear all redo moves when a property changes", function() {
		module.k = 8
		module.popHistory()
		module.k = 5
		module.popFuture()
		expect(module.k).toEqual(5)
	});

	it("should not store properties not present at creation", function() {
		module.c = 10
		expect(module.c).toEqual(undefined)
	});	
}); 
