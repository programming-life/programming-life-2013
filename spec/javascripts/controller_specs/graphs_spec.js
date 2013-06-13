describe("Graphs", function() {
	describe("when consctructed", function() {
		beforeEach( function() {
			controller = new Controller.Graphs();
			view = controller.view;
			viewSpy = {
				kill: jasmine.createSpy("kill"),
				draw: jasmine.createSpy("draw")
			}
			graph1 = new Controller.Graph( {}, viewSpy );
			graph2 = new Controller.Graph( {}, viewSpy );
			graph3 = new Controller.Graph( {}, viewSpy );
			controller.addChild( 1, graph1 );
			controller.addChild( 2, graph2 );
			controller.addChild( 3, graph3 );

		});

		it("should have defined a view", function() {
			expect( view ).toBeDefined();
		});

		describe("when clearing", function() {
			beforeEach( function() {
				spyOn( controller, "removeChild" );
				spyOn( view, "kill" );
				controller.clear();
			});

			it("should have removed all the graphs from the controller", function() {
				expect( controller.removeChild.callCount ).toBe( 3 );
			});

			it("should have killed the view", function() {
				expect( view.kill ).toHaveBeenCalled();
			});
		});

		describe("when showing", function() {
			describe("with default parameters", function() {
				beforeEach( function() {
					dataset = [1, 2, 3];
					datasets = {
						3 : [],
						4: dataset
					}

					graphCount = 0;
					for (value in controller.controllers() ) {
						if (controller.controller( value ) instanceof Controller.Graph && datasets[ value ] == undefined) {
							graphCount++;
						}
					}
					spyOn( View, "Graph" ).andReturn({
						draw: jasmine.createSpy("draw"),
						kill: jasmine.createSpy("kill"),
						show: jasmine.createSpy("show"),
					});

					spyOn( view , "remove" );
					spyOn( view , "add" );
					spyOn( controller, "removeChild" );
					spyOn( controller, "addChild" ).andCallThrough();

					controller.show( datasets );
				});


				it("should have removed the old graphs of which the data is no longer shown", function() {
					expect( view.remove.callCount ).toBe( graphCount );
					expect( controller.removeChild.callCount ).toBe( graphCount );
				});

				it("should have created new graphs for the new data", function() {
					expect( controller.addChild ).toHaveBeenCalled();
				});

				it("should have added the new graph view to our view", function() {
					expect( view.add ).toHaveBeenCalled();
				});
			});
			describe("with custom parameters", function() {
				beforeEach( function() {
					dataset = [1, 2, 3];
					datasets = {
						3 : [],
						4: dataset
					}

					graphCount = 0;
					for (value in controller.controllers() ) {
						if (controller.controller( value ) instanceof Controller.Graph && datasets[ value ] == undefined) {
							graphCount++;
						}
					}
					spyOn( View, "Graph" ).andReturn({
						draw: jasmine.createSpy("draw"),
						kill: jasmine.createSpy("kill"),
						show: jasmine.createSpy("show"),
					});

					spyOn( view , "remove" );
					spyOn( view , "add" );
					spyOn( controller, "removeChild" );
					spyOn( controller, "addChild" ).andCallThrough();

					controller.show( datasets, false, "id" );
				});


				it("should have removed the old graphs of which the data is no longer shown", function() {
					expect( view.remove.callCount ).toBe( graphCount );
					expect( controller.removeChild.callCount ).toBe( graphCount );
				});

				it("should have created new graphs for the new data", function() {
					expect( controller.addChild ).toHaveBeenCalled();
				});

				it("should have added the new graph view to our view", function() {
					expect( view.add ).toHaveBeenCalled();
				});
			});
		});
	});
});
