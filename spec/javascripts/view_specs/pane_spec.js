describe("Pane", function() {
	describe("when constructed", function() {
		beforeEach( function() {
			position = 0;
			view = new View.Pane( position );
		});

		it("should have set all the properties", function() {
			expect( view.position).toBe( position );
			expect( view._extended ).toBe( true );
			expect( view._buttonWidth ).toBe( 40 );
			expect( view._containerOptions ).toEqual( {} );
			expect( view._views ).toEqual( [] );
		});

		describe("when clearing", function() {
			beforeEach( function() {
				spy = {
					kill: jasmine.createSpy( "kill" )
				}
				view._views = [spy, spy, spy];
				view.clear();
			});

			it("should have called kill for each view in it's view", function() {
				expect( spy.kill.callCount ).toBe( view._views.length );
			});
		});

		describe("when killing", function() {
			describe("without drawing", function() {
				beforeEach( function() {
					view.kill();
				});

				it("elem should still be undefined", function() {
					expect( view._elem ).toBe( undefined );
				});
			});

			describe("after drawing", function() {
				beforeEach( function() {
					view.draw();
					view.kill();
				});

				it("elem should still be undefined", function() {
					expect( $(document).find(view._elem).length ).toBe( 0 );
				});
			});

		});


		afterEach( function() {
			view.kill();
		});
	});
});
