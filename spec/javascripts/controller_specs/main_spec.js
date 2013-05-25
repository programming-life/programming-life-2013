describe("Main", function() {
	var controller, view_name

	beforeEach( function() {
		div = $("<div id='paper'></div>")[0]
		controller = new Controller.Main( div )
		view_name = controller.view.constructor.name;
	});
	
	describe("when initialized", function() {
		it("should contain the main view", function() {
			expect( view_name ).toBe( "Main" );
		});
	});

	afterEach( function() {
				
		controller.view.kill()
		$("#paper").remove()
		$(".popover").remove()
	});

});
