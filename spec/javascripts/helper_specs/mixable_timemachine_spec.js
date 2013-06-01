describe("Mixin: TimeMachine", function() {
	
	var mixed;
	var methods = Mixin.TimeMachine.InstanceMethods;
	beforeEach( function() {
	
		mixed = _( { } ).extend( methods );
		
	});
	
	describe("when initialized", function() {
	
		beforeEach( function() {
			mixed._allowTimeMachine();
		});
		
		it( "should have set a private variable", function() {
			expect( mixed.tree ).toBeDefined();
		});
		
		describe("and action is added", function() {
		
			var action = 'foo'; 
			
			beforeEach( function() {
				spyOn( mixed.tree, 'add' )
				mixed.addUndoableEvent( action );
			});
			
			it( "should called tree adding", function() {
				expect( mixed.tree.add ).toHaveBeenCalledWith( action );
			});
			
			describe("and is undone", function() {
			
				var undo = jasmine.createSpy( 'undo' );
				var action = { undo: undo };
				
				beforeEach( function() {
					spyOn( mixed.tree, 'undo' ).andReturn( action );
					mixed.undo();
				});
				
				it( "should called tree undo", function() {
					expect( mixed.tree.undo ).toHaveBeenCalled();
				});
				
				it( "should undone the returned action", function() {
					expect( undo ).toHaveBeenCalled();
				});
				
				describe("and is redone", function() {
			
					var redo = jasmine.createSpy( 'redo' );
					var action = { redo: redo };
					
					beforeEach( function() {
						spyOn( mixed.tree, 'redo' ).andReturn( action );
						mixed.redo();
					});
					
					it( "should called tree redo", function() {
						expect( mixed.tree.redo ).toHaveBeenCalled();
					});
					
					it( "should redone the returned action", function() {
						expect( redo ).toHaveBeenCalled();
					});
				});
			});
		});
		
	});
	
	describe("when action is created", function() {
		
		var result;
		var desc = 'foo';
		beforeEach( function() {
			result = mixed._createAction( desc );
		});
		
		it( "should return a model action", function() {
			expect( result instanceof Model.Action ).toBeTruthy();
		});
	});
});
