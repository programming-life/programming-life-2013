describe("Main", function() {

	
	describe("when constructed", function() {
		beforeEach( function() {
			container = $("<div id='paper'></div>")[0]
			controller = new Controller.Main( container )
			view_name = controller.view.constructor.name;
		});

		it("should contain the main view", function() {
			expect( controller.view ).toBeDefined();
			expect( view_name ).toBe( "Main" );
		});
			
		afterEach( function() {
			controller.view.kill()
			container.remove()
		});
	});


});
