describe( "popover module view", function() {
	
	describe( "When using default constructor", function(){

		var model, module, view;

		beforeEach( function() {
			cell  = {
				getCompoundNames : jasmine.createSpy( "getCompoundNames" ),
				getMetaboliteNames : jasmine.createSpy( "getMetaboliteNames" ),
			};
			model = {
				id : "mockId",
				metadata : {
					properties : {}
				},
			};
			parent = {};
			cellView = {};
			view = new View.ModuleProperties( parent, cellView, cell, model );

		});

		afterEach( function() {
			 //view.__super__.kill();
		})

		it("a view should be created", function() {
			expect(view).toBeDefined();	
		});

		it( "should have a changes object", function(){
			expect( view._changes ).toBeDefined();
		});

		it( "should have compounds", function(){
			expect( cell.getCompoundNames ).toHaveBeenCalled();
		});

		it( "should have metabolites", function(){
			expect( cell.getMetaboliteNames ).toHaveBeenCalled();
		});

		it( "should have selectables", function(){
			expect( view._selectables ).toBeDefined();
		});

		it( "should be able to draw parameters", function() {
			returnValue = view._drawParameter();
			expect( returnValue ).toBeDefined();
		});

		it( "should be able to draw metabolites", function() {
			returnValue = view._drawMetabolite( "", "", "food");
			expect( returnValue ).toBeDefined();
		});

		it( "should be able to draw DNA", function() {
			returnValue = view._drawDNA();
			expect( returnValue ).toBeDefined();
		});

		it( "should be able to draw population", function() {
			returnValue = view._drawPopulation();
			expect( returnValue ).toBeDefined();
		});

		it( "should be able to draw compounds", function() {
			returnValue = view._drawCompound();
			expect( returnValue ).toBeDefined();
		});

		it( "should be able to draw enumeration", function() {
			returnValue = view._drawEnumeration("", "", "", {});
			expect( returnValue ).toBeDefined();
		});

		it( "should be able to return key values", function() {
			view._triggerChange( "mockKey", "mockValue" );
			expect( view._getCurrentValueFor( "mockKey" ) ).toBeDefined();
		});


	});
});