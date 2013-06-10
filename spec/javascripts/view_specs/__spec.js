describe("Base", function() {
	var view, paper, raphael, x, y;

	beforeEach( function() {
		x = 42;
		y = 24;
		raphael = Raphael(0, 0, 0, 0);
		paper = {
			set: jasmine.createSpy('set').andReturn(raphael.set()),
			circle: jasmine.createSpy('circle').andReturn(raphael.circle(x, y, 0))
		};
		view = new View.RaphaelBase(paper);
	});

	afterEach( function() {
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
				contents = view.draw(x, y);
			});

			it("should clear first", function() {
				expect(view.clear).toHaveBeenCalled();
			});

			it("should have drawn and return the contents", function() {
				expect(contents).toBeDefined();
			});

			describe("when moved to a new fixed position", function() {
				beforeEach( function() {
					spyOn(view, 'move').andCallThrough();
					view.moveTo(x, y);
				});

				it("should have been moved", function() {
					expect(view.move).toHaveBeenCalled();
					expect(view.x).toEqual(x);
					expect(view.y).toEqual(y);
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