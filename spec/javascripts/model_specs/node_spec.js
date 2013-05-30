xdescribe("Node", function() {
	var node;

	beforeEach( function() {
	});

	xdescribe("when a root node with children is constructed", function() {
		var left, right;
		var children;

		beforeEach( function() {
			left = new Model.Node( null, null );
			right = new Model.Node( null, null );
			children = [left, right];
			node = new Model.Node( null, null, children );
			left.parent = node;
			right.parent = node;
		});

		it("should contain the children", function() {		
			expect( node.children ).toBe( children );
		});

		it("should be the parent of its children", function() {
			expect( left.parent ).toBe( node );
			expect( right.parent ).toBe( node );
		});

		describe("when rebasing a child", function() {
			it("should have a new parent", function() {
				left.rebase( right );
				expect( left.parent ).toBe( right );
			});

			it("should no longer be the child of the old parent", function() {
				expect( node.children ).toMatch([right]);
			});

			it("should keep the branch indicater intact if it exists", function() {
				right.branch = right;
				left.rebase( right );
				expect( right.branch ).toBe( right );
			});

		});
	});
	

	describe("when a root node is constructed", function() {
		var nodeObject;

		beforeEach( function() {
			nodeObject = {test: "test"};
			node = new Model.Node(nodeObject, null);
		});

		it("should contain the object", function() {
			expect( node.object ).toEqual( nodeObject );
		});

		it("should have null as a parent", function() {
			expect( node.parent ).toEqual( null );
		});

		it("should have no children", function() {
			expect( node.children.length ).toEqual( 0 );
		});

		describe("when a child node is added", function() {
			var child;

			beforeEach( function() {
				child = new Model.Node(null, node);
			});

			it("should have the root node as its parent", function() {
				expect( child.parent ).toEqual( node );
			});

			it("should be a child of the root", function() {
				expect( node.children[0] ).toEqual( child );
			});
		});
	});
});
