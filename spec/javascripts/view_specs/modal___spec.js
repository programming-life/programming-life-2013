describe("Modal", function() {
	describe("when constructed", function() {
		beforeEach( function() {
			header = "";
			contents = {};
			id = 1;
			classname = "";
			view = new View.HTMLModal(header, contents, id, classname)
		});

		afterEach( function() {
			view.kill()
		})

		it("should have set all the properties", function() {
			expect( view._header ).toBe( header );
			expect( view._contents ).toBe( contents );
			expect( view.id ).toBe( id );
			expect( view._id ).toBe( id );
			expect( view._elem ).toBeDefined();
		});
		
		describe("when showing", function() {
			beforeEach( function() {
				spyOn( view._elem, "modal" );
				view.show();
			});

			it("should have set action to undefined", function() {
				expect( view._action ).toBe( undefined );
			});

			it("should have called modal", function() {
				expect( view._elem.modal ).toHaveBeenCalledWith( "show" );
			})
		});

		describe("when hiding", function() {
			beforeEach( function() {
				spyOn( view._elem, "modal" );
				view.hide();
			});

			it("should have called modal", function() {
				expect( view._elem.modal ).toHaveBeenCalledWith( "hide" );
			})
		});

		describe("when toggling", function() {
			beforeEach( function() {
				spyOn( view._elem, "modal" );
				view.toggle();
			});

			it("should have called modal", function() {
				expect( view._elem.modal ).toHaveBeenCalledWith( "toggle" );
			})
		});

		describe("when binding to close", function() {
			beforeEach( function() {
				spyOn( view, "_bind" );
				context = {};
				action = {};
				view.onClose( context, action );
			});

			it("should have called bind", function() {
				expect( view._bind ).toHaveBeenCalledWith( "modal.confirm.close", context, action );
			});
		});

		describe("when unbinding to close", function() {
			beforeEach( function() {
				spyOn( view, "_unbind" );
				context = {};
				action = {};
				view.offClose( context, action );
			});

			it("should have called unbind", function() {
				expect( view._unbind ).toHaveBeenCalledWith( "modal.confirm.close", context, action );
			});
		});

		describe("when binding to closed", function() {
			beforeEach( function() {
				spyOn( view, "_bind" );
				context = {};
				action = {};
				view.onClosed( context, action );
			});

			it("should have called bind", function() {
				expect( view._bind ).toHaveBeenCalledWith( "modal.confirm.closed", context, action );
			});
		});

		describe("when unbinding to closed", function() {
			beforeEach( function() {
				spyOn( view, "_unbind" );
				context = {};
				action = {};
				view.offClosed( context, action );
			});

			it("should have called unbind", function() {
				expect( view._unbind ).toHaveBeenCalledWith( "modal.confirm.closed", context, action );
			});
		});

		afterEach( function() {
			view.kill();
		});
	});
});
