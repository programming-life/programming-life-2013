describe("Module", function() {
	describe("when constructed", function() {
		var module, paper, parent, model, cell;

		beforeEach( function() {
			paper = Raphael(0, 0, 0, 0);
			parent = {
				getViewPlacement: jasmine.createSpy('getViewPlacement')
			};
			model = {
				name: 'foo'
			};
			cell = {};
			spyOn(View, 'ModuleProperties');
			spyOn(View, 'ModuleNotification');
			module = new View.Module(paper, parent, cell, model);
		});

		afterEach( function() {
			module.kill();
		});

		it("should be defined", function() {
			expect(module).toBeDefined();
		});

		it("should be visible", function() {
			expect(module.visible).toBeTruthy();
		});

		it("should be able to generate a hash code based on the module name", function() {
			expect(module.hashCode()).toBeDefined();
		});

		it("should be able to generate a colour based on the module name", function() {
			expect(module.hashColor()).toBeDefined();
		});

		it("should be able to generate a colour based on a number", function() {
			expect(module.numToColor(42)).toBeDefined();
		});

		describe("when drawing as a specific module", function() {

			it("should be able to draw as a transporter", function() {
				expect(module.drawAsTransporter()).toBeDefined();
			});

			it("should be able to draw as a metabolite", function() {
				expect(module.drawAsMetabolite()).toBeDefined();
			});

			it("should be able to draw as a metabolism", function() {
				expect(module.drawAsMetabolism()).toBeDefined();
			});

			it("should be able to draw as a protein", function() {
				expect(module.drawAsProtein()).toBeDefined();
			});

			describe("when drawing as a DNA, lipid or cell growth", function() {
				beforeEach( function() {
					spyOn(module, 'drawAsBasic');
					module.drawAsDNA();
					module.drawAsLipid();
					module.drawAsCellGrowth();
				});

				it("should draw the basic module", function() {
					expect(module.drawAsBasic.callCount).toEqual(3);
				});
			});
		});
		
		describe("after drawing the view", function() {
			var drawn;

			beforeEach( function() {
				spyOn(module, 'drawContents').andCallThrough();
				spyOn(module, 'drawMetaContents').andCallThrough();
				drawn = module.draw();
			});

			it("should have drawn the contents", function() {
				expect(module.drawContents).toHaveBeenCalled();
			});

			it("should have drawn the meta contents", function() {
				expect(module.drawMetaContents).toHaveBeenCalled();
			});

			it("should be able to redraw", function() {
				module.redraw();
				expect(module.drawContents.callCount).toEqual(2);
			});			
		});

		describe("without interaction", function() {
			beforeEach( function() {
				module = new View.Module(paper, parent, cell, model, false);
			});

			afterEach( function() {
				module.kill();
			});

			it("should be defined", function() {
				expect(module).toBeDefined();
			});

			it("should not automatically add interaction", function() {
				spyOn(module, 'addInteraction');

				expect(module.addInteraction).not.toHaveBeenCalled();
			});

			it("should not add interaction after drawing", function() {
				var contents = module.drawContents();
				spyOn(module, 'addHitBoxInteraction');
				module.drawMetaContents(contents);

				expect(module.addHitBoxInteraction).not.toHaveBeenCalled();
			});

			it("should be able to manually add interaction", function() {
				spyOn(module, '_onNotificate')
				module.addInteraction();

				expect(module._onNotificate).toHaveBeenCalled();
			});
		});
	});
});