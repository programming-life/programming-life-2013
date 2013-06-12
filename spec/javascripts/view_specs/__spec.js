describe("Base", function() {
	var view, parent, paper, raphael, draw_x, draw_y, x, y;

	beforeEach( function() {
		draw_x = 42;
		draw_y = 24;
		x = 10;
		y = 20;
		paper = Raphael(x, y, 30, 40);
		parent = {
			getViewPlacement: jasmine.createSpy('getViewPlacement'),
			getAbsoluteCoords: jasmine.createSpy('getAbsoluteCoords')
		};
		view = new View.RaphaelBase(paper, parent);
	});

	afterEach( function() {
		view._paper = raphael;
		view.kill();
	});

	describe("when constructed", function() {
		it("should have set the paper", function() {
			expect(view.paper).toBe(paper);
		});

		it("should be able to get x and y when nothing is set", function() {
			expect(view.x).toEqual(0);
			expect(view.y).toEqual(0);
		});

		describe("when drawn", function() {
			var contents;

			beforeEach( function() {
				spyOn(view, 'clear').andCallThrough();
				contents = view.draw(draw_x, draw_y);
			});

			it("should get the right bounding box", function() {
				var BBox = {
					x: draw_x,
					y: draw_y,
					x2: draw_x,
					y2: draw_y,
					width: 0,
					height: 0
				};

				expect(view.getBBox()).toEqual(BBox);
			});

			it("should clear first", function() {
				expect(view.clear).toHaveBeenCalled();
			});

			it("should have drawn and return the contents", function() {
				expect(contents).toBeDefined();
			});

			it("should be able to set a new x position", function() {
				view.x = 40;
				expect(view.x).toEqual(40);
			});

			it("should be able to set a new y position", function() {
				view.y = 30;
				expect(view.y).toEqual(30);
			});

			it("should be able to get the absolute coordinates", function() {
				expect(view.getAbsoluteCoords(20, 40)).toEqual([x+20, y+40]);
			});

			describe("when moved to a new fixed position", function() {
				beforeEach( function() {
					spyOn(view, 'move').andCallThrough();
					view.moveTo(12, 24, false);
				});

				it("should have been moved", function() {
					expect(view.move).toHaveBeenCalled();
					expect(view.x).toEqual(12);
					expect(view.y).toEqual(24);
				});
			});

			describe("when moved to a new position relative to its parent", function() {
				beforeEach( function() {
					spyOn(view, 'moveTo').andCallThrough();
					view.setPosition();
				});

				it("should do nothing when parent is null", function() {
					expect(view.moveTo).not.toHaveBeenCalled();
				});

				it("should move to the new position", function() {
					view.moveTo.reset();
					parent = {
						getViewPlacement: jasmine.createSpy('getViewPlacement').andReturn([2,4])
					};
					view._parent = parent;

					view.setPosition(false);

					expect(view.moveTo).toHaveBeenCalled();
					expect(view.x).toEqual(2);
					expect(view.y).toEqual(4);
				})
			});

			describe("when redrawn", function() {
				beforeEach( function() {
					spyOn(view, 'draw');
					view.redraw();
				});

				it("should have redrawn and return the contents", function() {
					expect(view.draw).toHaveBeenCalled();
				});
			});
		});
	});
});