describe( "Module Metabolite", function() {

	describe( "When using default constructor", function() {

		var module;
		beforeEach( function() {
			module = new Model.Metabolite();
		});

		it( "should have no name", function() {
			expect( module.name ).toBe( "undefined#ext" );
		});
		
		it( "should be able to set the name", function() {
			module.name = 'magix'
			expect( module.name ).toBe( "magix#ext" );
		});

		it( "should be outside the cell", function() {
			expect( module.placement ).toBe( Model.Metabolite.Outside );
		});
		
		it( "should be a substrate", function() {
			expect( module.type ).toBe( Model.Metabolite.Substrate );
		});

		it( "should have 1 substrate: name with value 1", function() {
			expect( _( module.starts ).size() ).toBe( 1 );
			expect( module.starts.name ).toBeDefined();
			expect( module.starts.name ).toBe( 1 );
		});
		
		it("should be able to serialize the module", function() {
			serialized = module.serialize( true )
			expect( serialized ).toBeDefined();
			expect( serialized.length ).toBeGreaterThan( 2 )
		});
		
		it( "should have supply of 1", function() {
			expect( module.supply ).toBe( 1 );
		});
		
		describe("and when serialized", function() {
			var serialized;
			beforeEach( function() {
				serialized = module.serialize( true )
			});
			
			it("should be able to deserialize", function() {
				deserialized = Model.Metabolite.deserialize( serialized )
				expect( deserialized ).toBeDefined();
				expect( deserialized.constructor.name ).toBe( module.constructor.name )
			});
			
			describe("and when deserialized", function() {
				var deserialized;
				beforeEach( function() {
					deserialized = Model.Metabolite.deserialize( serialized )
				});
				
				it( "should have no name", function() {
					expect( module.name ).toBe( "undefined#ext" );
				});

				it( "should be outside the cell", function() {
					expect( module.placement ).toBe( Model.Metabolite.Outside );
				});
				
				it( "should be a substrate", function() {
					expect( module.type ).toBe( Model.Metabolite.Substrate );
				});

				it( "should have 1 substrate: name with value 1", function() {
					expect( _( module.starts ).size() ).toBe( 1 );
					expect( module.starts.name ).toBeDefined();
					expect( module.starts.name ).toBe( 1 );
				});
		
				it( "should have a _step function", function() {
					expect( deserialized._step ).toBeDefined();
				});
			});
		});

	});

	describe( "When using parameters in the constructor", function() {

		var module;
		beforeEach( function() {
			module = new Model.Metabolite( { x: "new", name: "override_substrate" } );
		});

		it( "should have the new parameters" , function() {
			expect( module.x ).toBeDefined();
			expect( module.x ).toBe( "new" );
		})

		it( "should override default parameters", function() {
			expect( module.name ).toBe( "override_substrate#ext" );
		});

	});

	describe( "When using name option, not as parameter", function() {

		var module;
		beforeEach( function() {
			module = new Model.Metabolite( undefined, undefined, "named_substrate");
		});

		it( "should override the default name", function() {
			expect( module.name ).toBe( "named_substrate#ext" );
		});

	});

	describe( "When using name option and as parameter", function() {

		var module;
		beforeEach( function() {
			module = new Model.Metabolite( { name: "param_substrate"}, undefined, "named_substrate" );
		});

		it( "should not override parameterized name", function() {
			expect( module.name ).toBe( "param_substrate#ext" );
		});
	});

	describe( "When using the start option", function() {

		var module;
		beforeEach( function() {
			module = new Model.Metabolite( undefined, 2 );
		});

		it( "should override the default value", function(){
			expect( module.starts.name ).toBe( 2 );
		});
		
	});
	
	describe( "When using the placement option", function() {

		describe( "and inside cell", function() {
			
			var module;
			beforeEach( function() {
				module = new Model.Metabolite( undefined, 2, undefined, Model.Metabolite.Inside );
			});

			it( "should have the correct placement", function(){
				expect( module.placement ).toBe( Model.Metabolite.Inside );
			});
		});
		
		describe( "and outside cell", function() {
			
			var module;
			beforeEach( function() {
				module = new Model.Metabolite( undefined, 2, undefined, Model.Metabolite.Outside );
			});

			it( "should have the correct placement", function(){
				expect( module.placement ).toBe( Model.Metabolite.Outside );
			});
		});
		
	});
	
	describe( "When using the type option", function() {

		describe( "and is product", function() {
			
			var module;
			beforeEach( function() {
				module = new Model.Metabolite( undefined, 2, undefined, undefined, Model.Metabolite.Product );
			});

			it( "should have the correct type", function(){
				expect( module.type ).toBe( Model.Metabolite.Product );
			});
		});
		
		describe( "and is substrate", function() {
			
			var module;
			beforeEach( function() {
				module = new Model.Metabolite( undefined, 2, undefined, undefined, Model.Metabolite.Substrate );
			});

			it( "should have the correct type", function(){
				expect( module.type ).toBe( Model.Metabolite.Substrate );
			});
		});
	});
	
	describe( "when using external substrate constructor", function() {

		describe( "with default values", function() {
			var module;
			beforeEach( function() {
				module = Model.Metabolite.sext();
			});

			it( "should have name s", function() {
				expect( module.name ).toBe( "s#ext" );
			});
			
			it( "should be able to set the name", function() {
				module.name = 'magix'
				expect( module.name ).toBe( "magix#ext" );
			});

			it( "should be inside the cell", function() {
				expect( module.placement ).toBe( Model.Metabolite.Outside );
			});
			
			it( "should be a substrate", function() {
				expect( module.type ).toBe( Model.Metabolite.Substrate );
			});
			
			it( "should have supply of 1", function() {
				expect( module.supply ).toBe( 1 );
			});
			
			it( "should have amount of 1", function() {
				expect( module.amount ).toBe( 1 );
			});
		});
		
		describe( "with custom values", function() {
			var module;
			beforeEach( function() {
				module = Model.Metabolite.sext( { foo: 'foo' }, 5, 7, 'bar' );
			});

			it( "should have the name", function() {
				expect( module.name ).toBe( "bar#ext" );
			});
			
			it( "should be able to set the name", function() {
				module.name = 'magix'
				expect( module.name ).toBe( "magix#ext" );
			});

			it( "should be outside the cell", function() {
				expect( module.placement ).toBe( Model.Metabolite.Outside );
			});
			
			it( "should be a substrate", function() {
				expect( module.type ).toBe( Model.Metabolite.Substrate );
			});
			
			it( "should have supply given", function() {
				expect( module.supply ).toBe( 5 );
			});
			
			it( "should have amount given", function() {
				expect( module.amount ).toBe( 7 );
			});
			
			it( "should have the custom params", function() {
				expect( module.foo ).toBe( "foo" );
			});
		});
	});
	
	describe( "when using internal substrate constructor", function() {

		describe( "with default values", function() {
			var module;
			beforeEach( function() {
				module = Model.Metabolite.sint();
			});

			it( "should have name s", function() {
				expect( module.name ).toBe( "s#int" );
			});
			
			it( "should be able to set the name", function() {
				module.name = 'magix'
				expect( module.name ).toBe( "magix#int" );
			});

			it( "should be inside the cell", function() {
				expect( module.placement ).toBe( Model.Metabolite.Inside );
			});
			
			it( "should be a substrate", function() {
				expect( module.type ).toBe( Model.Metabolite.Substrate );
			});
			
			it( "should have supply of 0", function() {
				expect( module.supply ).toBe( 0 );
			});
			
			it( "should have amount of 0", function() {
				expect( module.amount ).toBe( 0 );
			});
		});
		
		describe( "with custom values", function() {
			var module;
			beforeEach( function() {
				module = Model.Metabolite.sint( { foo: 'foo' }, 7, 'bar' );
			});
			
			it( "should have the name", function() {
				expect( module.name ).toBe( "bar#int" );
			});
			
			it( "should be able to set the name", function() {
				module.name = 'magix'
				expect( module.name ).toBe( "magix#int" );
			});

			it( "should be inside the cell", function() {
				expect( module.placement ).toBe( Model.Metabolite.Inside );
			});
			
			it( "should be a substrate", function() {
				expect( module.type ).toBe( Model.Metabolite.Substrate );
			});
			
			it( "should have supply 0", function() {
				expect( module.supply ).toBe( 0 );
			});
			
			it( "should have amount given", function() {
				expect( module.amount ).toBe( 7 );
			});
			
			it( "should have the custom params", function() {
				expect( module.foo ).toBe( "foo" );
			});
		});
	});
	
	describe( "when using internal product constructor", function() {

		describe( "with default values", function() {
			var module;
			beforeEach( function() {
				module = Model.Metabolite.pint();
			});

			it( "should have name p", function() {
				expect( module.name ).toBe( "p#int" );
			});
			
			it( "should be able to set the name", function() {
				module.name = 'magix'
				expect( module.name ).toBe( "magix#int" );
			});

			it( "should be inside the cell", function() {
				expect( module.placement ).toBe( Model.Metabolite.Inside );
			});
			
			it( "should be a product", function() {
				expect( module.type ).toBe( Model.Metabolite.Product );
			});
			
			it( "should have supply of 0", function() {
				expect( module.supply ).toBe( 0 );
			});
			
			it( "should have amount of 0", function() {
				expect( module.amount ).toBe( 0 );
			});
		});
		
		describe( "with custom values", function() {
			var module;
			beforeEach( function() {
				module = Model.Metabolite.pint( { foo: 'foo' }, 7, 'bar' );
			});
			
			it( "should have the name", function() {
				expect( module.name ).toBe( "bar#int" );
			});
			
			it( "should be able to set the name", function() {
				module.name = 'magix'
				expect( module.name ).toBe( "magix#int" );
			});

			it( "should be inside the cell", function() {
				expect( module.placement ).toBe( Model.Metabolite.Inside );
			});
			
			it( "should be a product", function() {
				expect( module.type ).toBe( Model.Metabolite.Product );
			});
			
			it( "should have supply 0", function() {
				expect( module.supply ).toBe( 0 );
			});
			
			it( "should have amount given", function() {
				expect( module.amount ).toBe( 7 );
			});
			
			it( "should have the custom params", function() {
				expect( module.foo ).toBe( "foo" );
			});
		});
	});
	
	describe( "when using external product constructor", function() {

		describe( "with default values", function() {
			var module;
			beforeEach( function() {
				module = Model.Metabolite.pext();
			});

			it( "should have name p", function() {
				expect( module.name ).toBe( "p#ext" );
			});
			
			it( "should be able to set the name", function() {
				module.name = 'magix'
				expect( module.name ).toBe( "magix#ext" );
			});

			it( "should be outside the cell", function() {
				expect( module.placement ).toBe( Model.Metabolite.Outside );
			});
			
			it( "should be a product", function() {
				expect( module.type ).toBe( Model.Metabolite.Product );
			});
			
			it( "should have supply of 0", function() {
				expect( module.supply ).toBe( 0 );
			});
			
			it( "should have amount of 0", function() {
				expect( module.amount ).toBe( 0 );
			});
		});
		
		describe( "with custom values", function() {
			var module;
			beforeEach( function() {
				module = Model.Metabolite.pext( { foo: 'foo' }, 7, 'bar' );
			});
			
			it( "should have name bar", function() {
				expect( module.name ).toBe( "bar#ext" );
			});
			
			it( "should be able to set the name", function() {
				module.name = 'magix'
				expect( module.name ).toBe( "magix#ext" );
			});

			it( "should be outside the cell", function() {
				expect( module.placement ).toBe( Model.Metabolite.Outside );
			});
			
			it( "should be a product", function() {
				expect( module.type ).toBe( Model.Metabolite.Product );
			});
			
			it( "should have supply 0", function() {
				expect( module.supply ).toBe( 0 );
			});
			
			it( "should have amount given", function() {
				expect( module.amount ).toBe( 7 );
			});
			
			it( "should have the custom params", function() {
				expect( module.foo ).toBe( "foo" );
			});
		});
	});
});