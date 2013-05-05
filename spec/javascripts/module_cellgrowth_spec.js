describe("Module Cell Growth", function() {
	
	describe( "When using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.CellGrowth();
		});

		it( "should have 'cell' as name", function() {
			expect( module.name ).toBe( "cell" );
		});

		it( "should have 's_int' as consume", function() {
			expect( module.consume ).toBe( "s_int" );
		});

		it( "should have an infrastructure", function() {
			expect( module.infrastructure ).toBeDefined();
			expect( module.infrastructure ).toMatch( [ "lipid", "protein" ] );
		});

		it( "should have 1 substrate: name", function() {
			expect( _(module.starts).size() ).toBe( 1 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
		})

	});

}); 
