describe("Node", function() {
	var node;

	beforeEach( function() {
	});

	describe("when a root node with children is constructed", function() {
		var left, right;
		var children;

		beforeEach( function() {
			left = new Node( null, null );
			right = new Node( null, null );
			children = [left, right];
			node = new Node( null, null, children );
			left._parent = node;
			right._parent = node;
		});

		it("should contain the children", function() {		
			expect( node._children ).toBe( children );
		});

		it("should be the parent of its children", function() {
			expect( left._parent ).toBe( node );
			expect( right._parent ).toBe( node );
		});

		describe("when rebasing a child", function() {
			it("should have a new parent", function() {
				left.rebase( right );
				expect( left._parent ).toBe( right );
			});

			it("should no longer be the child of the old parent", function() {
				expect( node._children ).toMatch([right]);
			});

			it("should keep the branch indicater intact if it exists", function() {
				right._branch = right;
				left.rebase( right );
				expect( right._branch ).toBe( right );
			});

		});
	});
	

	describe("when a root node is constructed", function() {
		var nodeObject;

		beforeEach( function() {
			nodeObject = {test: "test"};
			node = new Node(nodeObject, null);
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
				child = new Node(null, node);
			});

			it("should have the root node as its parent", function() {
				expect( child._parent ).toEqual( node );
			});

			it("should be a child of the root", function() {
				expect( node._children[0] ).toEqual( child );
			});
		});
	});
});
