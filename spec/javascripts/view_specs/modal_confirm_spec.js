describe("ConfirmModal", function() {
	describe("when constructed", function() {
		beforeEach( function() {
			header = "";
			contents = {};
			id = 1;
			classname = "";
			view = new View.ConfirmModal(header, contents, id, classname)
		});

		it("the modal should have a cancel button", function() {
			expect( view._elem.find("[data-action=\"cancel\"]").length ).toBe( 1 );
		});

		it("the modal should have a confirm button", function() {
			expect( view._elem.find("[data-action=\"confirm\"]").length ).toBe( 1 );
		});

		afterEach( function() {
			view.kill();
		});
	});
});
