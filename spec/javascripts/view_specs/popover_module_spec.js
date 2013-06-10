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
				mockKey : "mockValue",
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

		// it( "should be able to draw selectables", function() {
		// 	returnValue = view._drawSelectable();
		// 	expect( returnValue ).toBeDefined();
		// });

		describe( "when handling changes", function(){

			beforeEach( function() {
				view._triggerChange( "mockKey", "mockValue" );
			});

			it( "should be able to return key values", function() {
				expect( view._getCurrentValueFor( "mockKey" ) ).toBe( "mockValue" );
			});

			it( "should be able to draw custom selections", function(){
				expect( view._drawSelectionFor ).toBeDefined();
			});
		});

		it( "should be able to get module properties", function() {
			expect( view._getModuleProperties() ).toBeDefined();
		});

		it( "should be able to catch errors", function() {
			expect( view._catcher( {}, {message: "error caught"} ) ).toBeDefined();
		});

		it( "should be able to remove modules", function(){
			expect( view._remove ).toBeDefined();
		});

		it( "should be able to change compounds", function(){
			expect( view._onCompoundsChanged( cell, model ) ).toBeDefined();
		});
		
		it( "should be able to change metabolites", function(){
			expect( view._onMetabolitesChanged( cell, model ) ).toBeDefined();
		});

		it( "should be able to select modules", function(){
			view._onModuleSelected( cell, true );
			expect( cell._selected ).toBe( true );
		});

		it( "should be able to hover over modules", function(){
			view._onModuleHovered( cell, true );
			expect( cell._hovered ).toBe( true );
		});

		it( "should be able to invalidate modules", function(){
			expect( view._onModuleInvalidated ).toBeDefined();
		});

		it( "should be able to create modules", function(){
			expect( view._onModuleCreationStarted ).toBeDefined();
		});
	});
});