describe("Action", function() {

	describe("when constructed", function() {
	
		var action,func1,func2, context;
		
		beforeEach( function() {
		
			func1 = function() {
				this.k = 1
			};
			
			func2 = function() {
				this.k = 2
			};

			context = {
				k : 0,
				f1 : func1,
				f2 : func2
			}

			action = new Model.Action(context, func1, func2);
		});

		it("should have all the properties", function() {
			expect( action._todo ).toBe( func1 );
			expect( action._undo ).toBe( func2 );
			expect( action._context ).toBe( context );
		});

		describe("when having undone the action", function() {
			beforeEach( function() {
				action.undo();
			});

			it("should have executed the function on the context", function() {
				expect( context.k ).toBe( 2 );
			});
		});

		describe("when having redone the action", function() {
			beforeEach( function() {
				action.redo();
			});

			it("should have executed the function on the context", function() {
				expect( context.k ).toBe( 1 );
			});
		});
		
		describe("when set", function() {
			beforeEach( function() {
				func1 = func1 = function() {
					this.foo = 1
				};
			
				func2 = function() {
					this.bar = 2
				};
				
				action.set( func1, func2 );
			});

			it("should have the new functions", function() {
				expect( action._todo ).toBe( func1 );
				expect( action._undo ).toBe( func2 );
				expect( action._context ).toBe( context );
			});
		});

	});

});
