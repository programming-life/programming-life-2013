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
			spyOn(View, 'ModuleProperties').andReturn({
				setPosition: jasmine.createSpy('setPosition'),
			});
			spyOn(View, 'ModuleNotification');
			module = new View.Module(paper, parent, cell, model);
		});

		afterEach( function() {
			module._propertiesView = undefined;
			module._notificationsView = undefined;
			module.kill();
			paper.clear();
			paper.remove();
		});

		it("should be defined", function() {
			expect(module).toBeDefined();
		});

		it("should be visible", function() {
			expect(module._visible).toBeTruthy();
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

			it("should be able to draw as a DNA", function() {
				expect(module.drawAsDNA()).toBeDefined();
			});

			it("should be able to draw as a lipid", function() {
				expect(module.drawAsLipid()).toBeDefined();
			});

			it("should be able to draw as a cellgrowth", function() {
				expect(module.drawAsCellGrowth()).toBeDefined();
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
				module._propertiesView = undefined;
				module._notificationsView = undefined;
				module.kill();
			})

			it("should be defined", function() {
				expect(module).toBeDefined();
			});

			it("should not automatically add interaction", function() {
				spyOn(module, 'addInteraction');

				expect(module.addInteraction).not.toHaveBeenCalled();
			});

			it("should be able to manually add interaction", function() {
				module.addInteraction();

				expect(module._propertiesView).toBeDefined();
				expect(module._notificationsView).toBeDefined();
			});
		});
	});
});
