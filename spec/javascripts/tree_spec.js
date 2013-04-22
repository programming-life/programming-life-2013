describe("Tree", function() {
    var tree, root;
	var rootObject;
		
	beforeEach(function() {
	});
	
	describe("when a tree is constructed", function() {
	
		beforeEach( function() {
			rootObject = {test: "test"};
			root = new Node(rootObject, null);

			tree = new Tree(root);
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
				node = new Node(nodeObject, root);
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
	})
});
