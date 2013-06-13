describe("Graph", function() {
	describe("when constructed", function() {
		beforeEach( function() {
			view = {
				draw: function() {}
			};
			parent = {}
			controller = new Controller.Graph( parent, view );
		});

		it("should have created a new controller with its properties set", function() {
			expect( controller.view ).toBe( view );
		});

		describe("when a dataset is added", function() {
			beforeEach( function() {
				data = [];
				controller.add( data );
			});

			it("should have added that dataset first on the list of datasets", function() {
				expect( controller._datasets[0] ).toBe( data );
			});
		});

		describe("when a dataset is appended to an empty list", function() {
			beforeEach( function() {
				data = [];
				controller.append( data );
			});

			it("should have added that dataset as first on the list of datasets", function() {
				expect( controller._datasets[0] ).toBe( data );
			});
		});

		describe("when a dataset is appended to a list with one dataset", function() {
			beforeEach( function() {
				data = {}
				data.xValues = [ 1 ];
				data.yValues = [ 2 ];
				controller.add( data );
				toAppend = {};
				toAppend.xValues = [ 3 ];
				toAppend.yValues = [ 4 ];
				controller.append( toAppend );
			});

			it("should have appended that dataset to the most recently added dataset", function() {
				for (i = 1; i <= toAppend.xValues.length; i++) {
					expect( controller._datasets[0].xValues[data.xValues.length - i] ).toBe( toAppend.xValues[ toAppend.xValues.length - i] );
				}
				for (i = 1; i <= toAppend.yValues.length; i++) {
					expect( controller._datasets[0].yValues[data.yValues.length - i] ).toBe( toAppend.yValues[ toAppend.yValues.length - i] );
				}
			});
		});

		describe("when showing a dataset", function() {
			beforeEach( function() {
				data = {}
				data.xValues = [ 1, 3 ];
				data.yValues = [ 2, 4 ];

				spyOn( view, "draw" );
			});

			describe("when automagically and append", function() {
				beforeEach( function() {
					oldXLength = data.xValues.length;
					oldYLength = data.yValues.length;

					controller.show( data , true)
				});
				it("should have removed the first x and y value", function() {
					expect( data.xValues.length ).toBe( oldXLength - 1 );
					expect( data.yValues.length ).toBe( oldYLength - 1 );
				});
			});

			describe("when not automagically", function() {
				beforeEach( function() {
					controller._automagically = false;
					oldXLength = data.xValues.length;
					oldYLength = data.yValues.length;

					controller.show( data )
				});
				it("should not have removed the first x and y value", function() {
					expect( data.xValues.length ).toBe( oldXLength );
					expect( data.yValues.length ).toBe( oldYLength );
				});
			});

			describe("when not appending", function() {
				beforeEach( function() {
					spyOn( controller, "add" );
					spyOn( controller, "append" );
					controller.show( data, false )
				});
				it("should have added that dataset as first on the list of datasets", function() {
					expect( controller.add ).toHaveBeenCalledWith( data );
				});

				it("should not have append the dataset", function() {
					expect( controller.append ).not.toHaveBeenCalled();
				});
			});

			describe("when appending", function() {
				beforeEach( function() {
					controller.add( data );

					toAppend = {};
					toAppend.xValues = [ 3 ];
					toAppend.yValues = [ 4 ];

					spyOn( controller, "add" );
					spyOn( controller, "append" );
				});
				it("should not have added that dataset to the list of datasets", function() {
					expect( controller.add ).not.toHaveBeenCalled();
				});

				it("should have appended that dataset to the most recently added dataset", function() {
					for (i = 1; i <= toAppend.xValues.length; i++) {
						expect( controller._datasets[0].xValues[data.xValues.length - i] ).toBe( toAppend.xValues[ toAppend.xValues.length - i] );
					}
					for (i = 1; i <= toAppend.yValues.length; i++) {
						expect( controller._datasets[0].yValues[data.yValues.length - i] ).toBe( toAppend.yValues[ toAppend.yValues.length - i] );
					}
				});
			});


			it("should have drawn the graph", function() {
				controller.show( data, true );
				expect( view.draw ).toHaveBeenCalledWith( controller._datasets );
			});
		});
	});
});
