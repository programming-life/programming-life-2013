describe("Tree", function() {
    var tree, root;
	var rootObject;
		
	beforeEach(function() {
	});

	describe("when a tree is contructed without a root", function() {
		beforeEach( function() {
			tree = new Model.Tree();
		});

		it("should have a default root node", function() {
			expect( tree._root._parent ).toBe( null );
			expect( tree._root._object).toBe( null );
			expect( tree._root._children.length).toBe( 0 );
		});
		
		it("the current node should be the root node", function() {
			expect( tree._current ).toBe( tree._root );
		});
	});
	
	describe("when a tree is constructed", function() {
	
		beforeEach( function() {
			rootObject = "root";
			root = new Model.Node(rootObject, null);

			tree = new Model.Tree(root);
		});
		
		it("should have the provided root as a root", function() {
			expect( tree._root ).toEqual( root );
		});

		it("should be able to find the object contained in root", function() {
			expect( tree.find(rootObject) ).toEqual( root );
		});

		describe("when a node has been added", function() {
			var node, nodeObject;

			beforeEach( function() {
				nodeObject = {test: "test2"};
				node = new Model.Node(nodeObject, root);
				tree.add( node );
			});

			it("should have root as a parent", function() {
				expect( node._parent ).toEqual( root );
			});

			it("should have added the new node to the children of it's parent", function() {
				expect( node._parent._children[0] ).toEqual( node );
			});

			describe("when the node is searched for", function() {
				var found;

				beforeEach( function() {
					found = tree.find(nodeObject);
				});

				it("should be found", function() {
					expect( found ).toEqual( node );
				});
			});
		});
		describe("when a big tree is constructed", function() {
			var nodes;
			beforeEach( function() {
				nodes = [root];
				for (i = 1; i < 5; i++) {
					nodes[i] = tree.add("test"+i, nodes[i-1]);
				}
				for (i = 5; i < 9; i++) {
					nodes[i] = tree.add("test"+i, nodes[i-5]);
				}
				
			});

			it( "should be able to generate a breadthfirst iterator", function() {
				it = tree.iterator()
				expected = [0,1,5,2,6,3,7,4,8]
				for (i = 0; i < it.length; i++ ) {
					expect( it[i] ).toBe( nodes[expected[i]] );
				}
			});

			it( "should be able to generate a depthfirst iterator", function() {
				it = tree.depthfirst()
				expected = [0,1,2,3,4,8,7,6,5]
				for (i = 0; i < it.length; i++ ) {
					expect( it[i] ).toBe( nodes[expected[i]] );
				}
			});

			it( "should be able to switch branches", function() {
				oldBranch = nodes[1]._parent._branch
				tree.switchBranch( nodes[1] )
				expect( oldBranch ).not.toBe( nodes[1]._parent._branch );
				expect( nodes[1]._parent._branch ).toBe( nodes[1] );
			});

		});

		describe("when a node is added", function() {
			var node,previous;
			beforeEach( function() {
				node = new Model.Node(null,null)
				previous = tree._current;
				tree.addNode(node);
			});

			it("should have added that node to the tree", function() {
				expect( tree._current ).toBe( node );
			});

			it("should have updated the parent of that node to the previous node", function() {
				expect( node._parent ).toBe( previous );
			});
			
		});

	})

});
