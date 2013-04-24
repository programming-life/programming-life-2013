describe("UndoTree", function() {
	var tree, root;
	
	beforeEach( function() {
		root = new Node({root: "test"}, null);
		tree = new UndoTree(root);
	});

	describe("when constructed with only a root node", function() {
		var undo, redo;
		beforeEach( function() {
			undo = tree.undo();
			redo = tree.redo();
		});

		it("should return null on undo", function() {
			expect( undo ).toBe( null );
		});

		it("should return null on redo", function() {
			expect( redo ).toBe( null );
		});
	});

	describe("when constructed with specific objects", function() {
		var test;
		var node, object;

		beforeEach( function() {
			node = [root];
			object = [null];
			for(i=1; i<6; i++) {
				object[i] = {test: i};
				node[i] = tree.add(object[i]);
			}
		});

		it("should have the node that was added last as current", function() {
			expect( tree._current ).toBe( node[5] );
		});

		describe("when undo has been called", function() {
			var undone, redone;

			beforeEach( function() {
				undone = tree.undo();
			});

			it("should have the second last node as current", function() {
				expect( tree._current ).toBe( node[4] );
			});

			it("should have returned the last action", function() {
				expect( undone ).toBe( object[5] );
			});

			describe("when undo has been called again", function() {

				beforeEach( function() {
					undone = tree.undo();
				});

				it("should have the third last node as current", function() {
					expect( tree._current ).toBe( node[3] );
				});

				it("should have returned the second last action", function() {
					expect( undone ).toBe( object[4] );
				});

				describe("when a new node is added to the tree", function() {
					var newNode;
					beforeEach( function() {
						newNode = tree.add({test: "new"});
					});

					it("should have switched the branch", function() {
						expect( tree._current ).toBe( newNode );
						expect( tree._current._parent._children.length ).toBe( 2 );
					});

					describe("when undoing", function() {
						beforeEach( function() {
							tree.undo();
						});

						describe("and then redoing", function() {
							beforeEach( function() {
								tree.redo();
							});

							it("should have the same tree", function() {
								expect( tree._current ).toBe( newNode );
								expect( tree._current._parent._children.length ).toBe( 2 );
							});
						});

						describe("and the old branch node is added again to the tree", function() {
							beforeEach( function() {
								oldBranchNode = tree.add( object[4] );
							});

							it("should have switched the branch to the old branch", function() {
								expect( tree._current ).toBe( oldBranchNode );
							});

							it("should not have added a node", function() {
								expect( tree._current._parent._children.length ).toBe( 2 );
							});
						});
					});

				});
			});

			describe("when redo has been called", function() {

				beforeEach( function() {
					redone = tree.redo();
				});

				it("should have the last node as current", function() {
					expect( tree._current ).toBe( node[5] );
				});

				it("should have returned the next action", function() {
					console.log( tree._current );
					expect( redone ).toBe( object[5] );
				});
			});
		});
	});
});
