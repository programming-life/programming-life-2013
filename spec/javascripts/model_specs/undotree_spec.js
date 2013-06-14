describe("UndoTree", function() {
	var tree, root;
	
	beforeEach( function() {
		root = new Model.Node({root: "root"}, null);
		tree = new Model.UndoTree(root);
	});

	describe("when a tree is contructed without a root", function() {
		beforeEach( function() {
			tree.root = new Model.UndoTree();
		});

		it("the current node should be the root node", function() {
			expect( tree.current ).toBe( root );
		});
	});

	describe("when constructed with only a root node", function() {
		beforeEach( function() {
		});

		describe("when undo is called", function() {
			var undo;
			beforeEach( function() {
				undo = tree.undo();
			});

			it("should return null on undo", function() {
				expect( undo ).toBe( null );
			});
		});

		describe("when redo is called", function() {
			var redo;
			beforeEach( function() {
				redo = tree.redo();
			});

			it("should return null on redo", function() {
				expect( redo ).toBe( null );
			});
		});

		describe("when rebasing the tree to a new node", function() {
			var newNode;
			beforeEach( function() {
				newNode = new Model.Node({base: "base"},null);
				tree.rebase(root, newNode);
			});

			it("should have replaced the root node with the new node", function() {
				expect( tree.root ).toEqual( newNode );
			});
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
			expect( tree.current ).toBe( node[5] );
		});

		describe("when undo has been called", function() {
			var undone, redone;

			beforeEach( function() {
				undone = tree.undo();
			});

			it("should have the second last node as current", function() {
				expect( tree.current ).toBe( node[4] );
			});

			it("should have returned the last action", function() {
				expect( undone ).toBe( object[5] );
			});

			describe("when undo has been called again", function() {

				beforeEach( function() {
					undone = tree.undo();
				});

				it("should have the third last node as current", function() {
					expect( tree.current ).toBe( node[3] );
				});

				it("should have returned the second last action", function() {
					expect( undone ).toBe( object[4] );
				});
				
				describe("when redo has been called", function() {

					beforeEach( function() {
						redone = tree.redo();
					});

					it("should have the second last node as current", function() {
						expect( tree.current ).toBe( node[4] );
					});

					it("should have returned the second last action", function() {
						expect( redone ).toBe( object[4] );
					});

					it("should have returned the same action as the object of the node that is now current", function() {
						expect( tree.current.object ).toBe( redone)
					});
				});

				describe("when a new node is added to the tree", function() {
					var newNode;
					beforeEach( function() {
						newNode = tree.add({test: "new"});
					});

					it("should have switched the branch", function() {
						expect( tree.current ).toBe( newNode );
						expect( tree.current.parent.children.length ).toBe( 2 );
					});

					describe("when undoing", function() {
						beforeEach( function() {
							tree.undo();
						});
						
						describe("and the old branch node is added again to the tree", function() {
							beforeEach( function() {
								oldBranchNode = tree.add( object[4] );
							});

							it("should have switched the branch to the old branch", function() {
								expect( tree.current ).toBe( oldBranchNode );
							});
						});

						describe("and then redoing", function() {
							beforeEach( function() {
								tree.redo();
							});

							it("should have the same tree", function() {
								expect( tree.current ).toBe( newNode );
								expect( tree.current.parent.children.length ).toBe( 2 );
							});
						});

					});

				});
			});

		});

		describe("when rebasing a branch", function() {
			
			beforeEach( function() {
				branch = node[2];
				base = new Model.Node({rebase: "base"});
				oldParent = branch.parent;
				tree.rebase( branch, base );
			});

			it("should have a branch with the new parent", function() {
				expect( branch.parent ).toBe( base );
			});

			it("should have differing old and new parents", function() {
				expect( branch.parent).not.toBe( oldParent );
			});

		});

		describe("when jumping from one node to another", function() {
			var jump;
			beforeEach( function() {
				for (i = 0; i<6;i++) {
					tree.undo();
				}
				newNode = tree.add({newNode: "new"});
				for (i = 0; i<6;i++) {
					tree.redo();
				}
				rightOrder = {
					reverse : [newNode,root],
					forward: node
				}
				order = tree.jump(node[5])
			});

			it("should have set the tree to the node", function() {
				expect( tree.current ).toBe( node[5] );
			});

			it("should have returned the nodes in between in the right order", function() {
				for (i = 0; i < order.reverse.length; i++) {
					expect( order.reverse[i] ).toBe( rightOrder.reverse[i] );
				}
				for (i = 0; i < order.forward.length; i++) {
					expect( order.forward[i] ).toBe( rightOrder.forward[i] );
				}
			});
		});
	});
});
