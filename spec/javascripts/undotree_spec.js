describe("UndoTree", function() {
	describe("when constructed with specific objects", function() {
		var tree, root ,test;
		var node, object;

		beforeEach( function() {
			root = new Node({root: "test"}, null);
			tree = new UndoTree(root);
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
