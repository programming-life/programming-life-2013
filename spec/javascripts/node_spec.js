describe("Node", function() {
	var node;

	beforeEach( function() {
	});

	describe("when a root node is constructed", function() {
		var nodeObject;

		beforeEach( function() {
			nodeObject = {test: "test"};
			node = new Model.Node(nodeObject, null);
		});

		it("should contain the object", function() {
			expect( node._object ).toEqual( nodeObject );
		});

		it("should have null as a parent", function() {
			expect( node._parent ).toEqual( null );
		});

		it("should have no children", function() {
			expect( node._children.length ).toEqual( 0 );
		});

		describe("when a child node is added", function() {
			var child;

			beforeEach( function() {
				child = new Model.Node(null, node);
			});

			it("should have the root node as it's parent", function() {
				expect( child._parent ).toEqual( node );
			});

			it("should be a child of the root", function() {
				expect( node._children[0] ).toEqual( child );
			});
		});
	});

});
