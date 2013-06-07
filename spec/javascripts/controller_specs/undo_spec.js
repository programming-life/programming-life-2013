describe("Undo", function() {
	var model, view;

	beforeEach( function() {
		model = new Model.UndoTree();
	});

	describe("when constructed", function() {
		var controller;
		
		beforeEach( function() {
			controller = new Controller.Undo( model);
			view = controller.view
		});

		it("should have a defined model", function() {
			expect( controller.model ).toBeDefined();
		});

		it("should have a defined view", function() {
			expect( controller.view ).toBeDefined();
		});

		describe("when setting the timemachine", function() {
			var tm;

			beforeEach( function () {
				tm = {};
				spyOn( view, "setTree" );
				controller.setTimeMachine( tm );
			});

			it("should have set that timemachine in the view", function() {
				expect( view.setTree ).toHaveBeenCalledWith( tm );
			});
		});
		
		describe("when a node is selected in some other view", function() {
			beforeEach( function () {
				source = {};
				node = {};
				spyOn( controller, "jump" );
				spyOn( view,  "selectNode" );
				controller._onNodeSelected( source, node );
			});

			it("should not have jumped to that node", function() {
				expect( controller.jump ).not.toHaveBeenCalled();
			});

			it("should not have selected that node", function() {
				expect( view.selectNode ).not.toHaveBeenCalled();
			});
		});

		describe("when a node is selected in our view", function() {
			beforeEach( function () {
				source = view; 
				node = {};
				spyOn( controller, "jump" );
				spyOn( view,  "selectNode" );
				controller._onNodeSelected( source, node );
			});

			it("should have jumped to that node", function() {
				expect( controller.jump ).toHaveBeenCalledWith( node );
			});

			it("should have selected that node", function() {
				expect( view.selectNode ).toHaveBeenCalledWith( node );
			});
		});

		describe("when a branch is selected in some other view", function() {
			beforeEach( function() {
				source = {};
				direction = {};
				spyOn( controller, "branch" );
				controller._onBranch( source, direction );
			});

			it("should not have branched the timemachine", function() {
				expect( controller.branch ).not.toHaveBeenCalled();
			});
		});

		describe("when a branch is selected in our view", function() {
			beforeEach( function() {
				source = view;
				direction = {};
				spyOn( controller, "branch" );
				controller._onBranch( source, direction );
			});

			it("should have branched the timemachine", function() {
				expect( controller.branch ).toHaveBeenCalledWith( direction );
			});
		});

		describe("when jumping to a node", function() {
			beforeEach( function() {
				action = new Model.Action();
				spyOn( action, "undo" );
				spyOn( action, "redo" );
				
				node = new Model.Node( action );
				nodes = {
					reverse: [node, node],
					forward: [node, node, node]
				}
				
				spyOn( model, "jump" ).andReturn( nodes );
				controller.jump( node );
			});

			it("should have jumped the timemachine", function() {
				expect( model.jump ).toHaveBeenCalledWith( node );
			});

			it("should have undone all the reverse steps", function() {
				expect( action.undo.callCount ).toBe( 2 );
			});

			it("should have redone all the forward steps", function() {
				expect( action.redo.callCount ).toBe( 3 );
			});
		});

		describe("when branching left with no branch to go to", function() {
			beforeEach( function() {
				action = new Model.Action();
				spyOn( action, "undo" );
				spyOn( action, "redo" );
				
				node1 = new Model.Node( action );
				model.addNode( node1 );
				spyOn( model, "switchBranch" ).andReturn( node1 );

				direction = Model.UndoTree.LeftBranch
				controller.branch( direction );
			});

			it("should not have undone the old branch action and not have redone the new branch action", function() {
				expect( node1.object.undo ).not.toHaveBeenCalled();
				expect( node1.object.redo ).not.toHaveBeenCalled();
			});

			it("should not have switched the branch of the timemachine", function() {
				expect( model.switchBranch ).not.toHaveBeenCalled();
			});
		});

		describe("when branching right with no branch to go to", function() {
			beforeEach( function() {
				action = new Model.Action();
				spyOn( action, "undo" );
				spyOn( action, "redo" );
				
				node1 = new Model.Node( action );
				model.addNode( node1 );
				spyOn( model, "switchBranch" ).andReturn( node1 );

				direction = Model.UndoTree.RightBranch
				controller.branch( direction );
			});

			it("should not have undone the old branch action and not have redone the new branch action", function() {
				expect( node1.object.undo ).not.toHaveBeenCalled();
				expect( node1.object.redo ).not.toHaveBeenCalled();
			});

			it("should not have switched the branch of the timemachine", function() {
				expect( model.switchBranch ).not.toHaveBeenCalled();
			});
		});

		describe("when branching left with one branch to go to", function() {
			beforeEach( function() {
				action = new Model.Action();
				spyOn( action, "undo" );
				spyOn( action, "redo" );
				
				node1 = new Model.Node( action );
				node2 = new Model.Node( action );
				model.addNode( node2 );
				model.undo();
				model.addNode( node1);
				spyOn( model, "switchBranch" ).andReturn( node1 );

				direction = Model.UndoTree.LeftBranch
				controller.branch( direction );
			});

			it("should have undone the old branch action and redone the new branchaction", function() {
				expect( node1.object.undo.callCount ).toBe( 1 );
				expect( node2.object.redo.callCount ).toBe( 1 );
			});

			it("should have switched the branch of the timemachine", function() {
				expect( model.switchBranch ).toHaveBeenCalledWith( node2 );
			});
		});

		describe("when branching right with one branch to go to", function() {
			beforeEach( function() {
				action = new Model.Action();
				spyOn( action, "undo" );
				spyOn( action, "redo" );
				
				node1 = new Model.Node( action );
				node2 = new Model.Node( action );
				model.addNode( node2 );
				model.undo();
				model.addNode( node1);
				spyOn( model, "switchBranch" ).andReturn( node1 );

				direction = Model.UndoTree.RightBranch
				controller.branch( direction );
			});

			it("should have undone the old branch action and redone the new branchaction", function() {
				expect( node1.object.undo.callCount ).toBe( 1 );
				expect( node2.object.redo.callCount ).toBe( 1 );
			});

			it("should have switched the branch of the timemachine", function() {
				expect( model.switchBranch ).toHaveBeenCalledWith( node2 );
			});
		});

		describe("when branching left with more branches to go to", function() {
			beforeEach( function() {
				action = new Model.Action();
				spyOn( action, "undo" );
				spyOn( action, "redo" );
				
				node1 = new Model.Node( action );
				node2 = new Model.Node( action );
				node3 = new Model.Node( action );
				model.addNode( node3 );
				model.undo()
				model.addNode( node2 );
				model.undo();
				model.addNode( node1);
				spyOn( model, "switchBranch" ).andReturn( node1 );

				direction = Model.UndoTree.LeftBranch
				controller.branch( direction );
			});

			it("should have undone the old branch action and redone the new branchaction", function() {
				expect( node1.object.undo.callCount ).toBe( 1 );
				expect( node2.object.redo.callCount ).toBe( 1 );
			});

			it("should have switched the branch of the timemachine", function() {
				expect( model.switchBranch ).toHaveBeenCalledWith( node2 );
			});
		});

		describe("when branching right with more branches to go to", function() {
			beforeEach( function() {
				action = new Model.Action();
				spyOn( action, "undo" );
				spyOn( action, "redo" );
				
				node1 = new Model.Node( action );
				node2 = new Model.Node( action );
				node3 = new Model.Node( action );
				model.addNode( node3 );
				model.undo()
				model.addNode( node2 );
				model.undo();
				model.addNode( node1);
				spyOn( model, "switchBranch" ).andReturn( node1 );

				direction = Model.UndoTree.RightBranch
				controller.branch( direction );
			});

			it("should have undone the old branch action and redone the new branchaction", function() {
				expect( node1.object.undo.callCount ).toBe( 1 );
				expect( node2.object.redo.callCount ).toBe( 1 );
			});

			it("should have switched the branch of the timemachine", function() {
				expect( model.switchBranch ).toHaveBeenCalledWith( node3 );
			});
		});

		describe("when focussing a timemachine", function() {
			beforeEach( function() {
				action = new Model.Action();
				spyOn( action, "undo" );
				spyOn( action, "redo" );
				
				node1 = new Model.Node( action );
				node2 = new Model.Node( action );
				node3 = new Model.Node( action );
				timemachine = new Model.UndoTree();
				model.addNode( node1);
				model.addNode( node2 );
				model.addNode( node3 );
				myIterator = [node1, node2, node3];
				tmIterator = [node3]
				spyOn( timemachine, "iterator" ).andReturn( tmIterator );
				spyOn( model, "iterator").andReturn( myIterator );
				model.find = function() {
					if (arguments[0] == node3.object) {
						return node3;
					}
				}
				spyOn( model, "find" ).andCallThrough();
				spyOn( view, "setActive");
				spyOn( view, "setInactive");
				controller.focusTimeMachine( timemachine );
			});

			it("should have filtered out the common entries", function() {
				expect( model.find.callCount ).toBe( tmIterator.length );
				for (var i in model.find.argsForCall) {
					args = model.find.argsForCall[i];
					expect( args[0] ).toBe( tmIterator[i].object );
				}
			});

			it("should have set the common entries to active", function() {
				expect( view.setActive.callCount ).toBe( 1 );
				expect( view.setActive ).toHaveBeenCalledWith( node3 );
			});

			xit("should have set the other entries to inactive", function() {
				expect( view.setInactive.callCount ).toBe( 2 );
				expect( view.setInactive ).toHaveBeenCalledWith( node1 );
				expect( view.setInactive ).toHaveBeenCalledWith( node2 );
			});
		});
	});
});
