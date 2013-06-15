describe("LoadModal", function() {
	describe("when constructed", function() {
		beforeEach( function() {
			id = 1;
			classname = "";
			view = new View.LoadModal(id, classname)
		});

		it("should have set all the properties", function() {
			expect( view._header ).toBe( "Select a cell to load" );
			expect( view._contents ).toBe( '<div class="contents modal-load"></div>' );
			expect( view.id ).toBe( id );
			expect( view._id ).toBe( id );
			expect( view._elem ).toBeDefined();
			expect( view.cell ).toBe( null );
		});

		describe("when creating a footer", function() {
			beforeEach( function() {
				spyOn( view, "offClose" );
				spyOn( view, "onClose" );
				footer = view._createFooter();
			});

			it("should have called offClose", function() {
				expect( view.offClose ).toHaveBeenCalledWith( view, view._resetButton );
			});

			it("should have called onClose", function() {
				expect( view.onClose ).toHaveBeenCalledWith( view, view._resetButton );
			});

			it("should have created a footer", function() {
				expect( footer[0] ).toBeDefined();
			});

			it("should have created a cancel button", function() {
				expect( footer[1] ).toBeDefined();
			});

			it("should have created a local cache button", function() {
				expect( footer[2] ).toBeDefined();
			});
		});

		describe("when resetting button", function() {
			expect( $( '#origin-local-button' ).hasClass( "active" ) ).toBeFalsy();
		});

		describe("when showing", function() {
			beforeEach( function() {
				failSpy = {
					fail: jasmine.createSpy("fail")
				}
				doneSpy = {
					done : jasmine.createSpy("done").andReturn(failSpy),
				}
				spyOn( view._elem, "modal" );
				spyOn( Model.Cell, "loadList" ).andReturn(doneSpy);
				view.show();
			});

			it("should have set action to undefined", function() {
				expect( view._action ).toBe( undefined );
			});

			it("should have called modal", function() {
				expect( view._elem.modal ).toHaveBeenCalledWith( "show" );
			});

			it("should have loaded the cell list", function() {
				expect( Model.Cell.loadList ).toHaveBeenCalled();
			});

			it("should have set the handlers for done and fail", function() {
				expect( doneSpy.done ).toHaveBeenCalled();
				expect( failSpy.fail ).toHaveBeenCalled();
			});

		});

		describe("when listing cells", function() {
			beforeEach( function() {
				tbody = $("<div></div>")
				cells = [1,2,3,4];
				origin = "";
				view._listCells(tbody, cells, origin);
			});

			it("should have added the data for each cell", function() {
				expect( tbody.find("td").length ).toBe( 4 * cells.length );
			});

			it("should have added a dropdown for each cell", function() {
				expect( tbody.find("[class=\"btn-group\"]").length ).toBe( cells.length );
				expect( tbody.find("[data-toggle=\"dropdown\"]").length ).toBe( cells.length );
			});

			it("should have added a load button to the body and the dropdown for each cell", function() {
				expect( tbody.find("[data-action=\"load\"]").length ).toBe( 2 * cells.length );
			});

			it("should have added a clone button for each cell", function() {
				expect( tbody.find("[data-action=\"clone\"]").length ).toBe( cells.length );
			});

			xit("should have added a merge button for each cell", function() {
				expect( tbody.find("[data-action=\"merge\"]").length ).toBe( cells.length );
			});
			
		});

		afterEach( function() {
			view.kill();
		});
	});
});
