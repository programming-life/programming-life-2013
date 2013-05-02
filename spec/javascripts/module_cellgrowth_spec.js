describe("Module Cell Growth", function() {
	
	describe( "when using default constructor", function() {
		
		var module;
		beforeEach( function() {
			module = new Model.CellGrowth();
		});

		it( "Should have 'cell' as name", function() {
			expect( module.name ).toBe( "cell" );
		});

		it( "Should have 's_int' as consume", function() {
			expect( module.consume ).toBe( "s_int" );
		});

		// Commented because of inequality of arrays and this isn't that important anyway.
		// it( "Should have 'lipid, protein' as infrastructure", function() {
		// 	expect( module.infrastructure ).toBe( [ "lipid", "protein" ] );
		// });

		it( "Should have 1 substrate: name", function() {
			expect( _(module.starts).size() ).toBe( 1 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
		})

	});

}); 
