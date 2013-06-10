describe("Modal settings", function() {

	describe("when constructed", function() {

		beforeEach( function() {
			settings = {};
			id = 1;
			classname = "";
			view = new View.SettingsModal(settings, id, classname);
		});

		it( "should have set all the properties", function() {
			expect( view._header ).toBe( 'Settings' );
			expect( view.id ).toBe( id );
			expect( view._elem ).toBeDefined();
		});

		it( "should be able to get the input fields", function() {
			expect( view.getInput() ).toBeDefined();
		});

		it( "should be able to create a control section", function() {
			expect( view._createControlSection() ).toBeDefined();
		});

	});

});