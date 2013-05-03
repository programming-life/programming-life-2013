describe( "Module Substrate", function() {

	describe( "When using default constructor", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate();
		});

		it( "should have no name", function() {
			expect( module.name ).toBe( undefined );
		});

		it( "should be inside the cell", function() {
			expect( module.placement ).toBe ( -0.5 );
		});

		it( "should have 1 substrate: name with value 1", function() {
			expect( _( module.starts ).size() ).toBe( 1 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
		});

	});

	describe( "When using parameters in the constructor", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate( { x: "new", name: "override_substrate" } );
		});

		it( "should have the new parameters" , function() {
			expect( module.x ).toBeDefined();
			expect( module.x ).toBe( "new" );
		})

		it( "should override default parameters", function() {
			expect( module.name ).toBe( "override_substrate" );
		});

	});

	describe( "When using name option, not as parameter", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate( undefined, undefined, "named_substrate");
		});

		it( "should override the default name", function() {
			expect( module.name ).toBe( "named_substrate" );
		});

	});

	describe( "When using name option and as parameter", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate( { name: "param_substrate"}, undefined, "named_substrate" );
		});

		it( "should not override parameterized name", function() {
			expect( module.name ).toBe( "param_substrate" );
		});
	});

	describe( "When using the start option", function() {

		var module;
		beforeEach( function() {
			module = new Model.Substrate( undefined, 2 );
		});

		it( "should override the default value", function(){
			expect( module.starts.name ).toBe( 2 );
		});
		
	});

});