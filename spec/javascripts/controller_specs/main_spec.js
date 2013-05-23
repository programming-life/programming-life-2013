describe("Main", function() {
	var main;

	beforeEach( function() {
		div = $("<div id='paper'></div>")[0]
		console.log(div)
		main = new Controller.Main(div)
		view_name = main._view.constructor.name;
		main._view.kill()
		console.log(main);
	});
	
	describe("when initialized", function() {
		it("should contain the main view", function() {
			console.log(view_name);
			expect( view_name ).toBe( "Main" );
		});
	});


});
