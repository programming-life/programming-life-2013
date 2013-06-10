describe("Undo", function() {
	describe("when constructed", function() {
		beforeEach( function() {
			model = {
				root : {
				},
				current: {
				},

			};
			view = new View.Undo(model);
		});

		it("should have created bindings", function() {
			expect( view._bindings.length ).not.toBe( 0 );
		});

		it("should have initialized it's properties", function() {
			expect( view._rows ).toBeDefined();
		});

		describe("when creating bindings", function() {
			beforeEach( function() {
				spyOn( view, "_bind" ).andCallThrough();
				view._createBindings();
			});

			it("should have created the proper bindings", function() {
				expect( view._bind ).toHaveBeenCalledWith( "tree.node.added", view, view._onNodeAdd );
				expect( view._bind ).toHaveBeenCalledWith( "tree.root.set", view, view._onRootSet );
				expect( view._bind ).toHaveBeenCalledWith( "controller.undo.branch.finished", view, view._onBranch );
			});
		});

		describe("when clearing", function() {
			beforeEach( function() {
			});

			describe("without contents", function() {
				beforeEach( function() {
					view.clear();
				});

				it("should still have contents undefined", function() {
					expect( view._contents ).not.toBeDefined();
				});
			});

			describe("with contents", function() {
				beforeEach( function() {
					view.draw();
					view.clear();
				});

				it("should still have contents defined", function() {
					expect( view._contents ).toBeDefined();
				});

				it("should have removed contents from the document", function() {
					expect( $( document ).find(view._contents).length ).toBe( 0 );
				});

			});
		});

		describe("when killing", function() {
			describe("without contents", function() {
				beforeEach( function() {
					view.kill();
				});

				it("should still have elem undefined", function() {
					expect( view._elem ).not.toBeDefined();
				});
			});

			describe("with contents", function() {
				beforeEach( function() {
					view.draw();
					view.kill();
				});

				it("should still have elem defined", function() {
					expect( view._elem ).toBeDefined();
				});

				it("should have no elements in elem", function() {
					expect( $( document ).find(view._elem).length ).toBe( 0 );
				});
			});
		});

		describe("when drawing", function() {
			beforeEach( function() {
				spyOn( view, "kill" );
				spyOn( view, "_drawContents" );
				view.draw();
			});

			it("should have killed the view", function() {
				expect( view.kill ).toHaveBeenCalled();
			});

			it("should have drawn the contents", function() {
				expect( view._drawContents ).toHaveBeenCalled();
			});
		});

		describe("when drawing the contents", function() {
			beforeEach( function() {
				view.draw()
				spyOn( view, "clear" );
				spyOn( view, "_getTreeView" );
				spyOn( view, "selectNode" );
				view._drawContents();
			});

			it("should have cleared the contents", function() {
				expect( view.clear ).toHaveBeenCalled();
			});

			it("should have created the tree view", function() {
				expect( view._getTreeView ).toHaveBeenCalled();
			});

			it("should have selected the active node", function() {
				expect( view.selectNode ).toHaveBeenCalledWith( model.current );
			});

			describe("when showing the buttons", function() {
				beforeEach( function() {
					view._showButtons();
				});

				it("should have set the buttons to active", function() {
					expect( view._footer.hasClass( "active-buttons" ) ).toBeTruthy();
				});
			});

			describe("when hiding the buttons", function() {
				beforeEach( function() {
					view._hideButtons();
				});

				it("should have set the buttons to active", function() {
					expect( view._footer.hasClass( "active-buttons" ) ).toBeFalsy();
				});
			});

			describe("when a node has been added", function() {
				describe("that is not out timemachine", function() {
					beforeEach( function() {
						model = {};
						node = {};
						ret = view._onNodeAdd(model, node);
					});

					it("should have done nothing", function() {
						expect( ret ).toBeFalsy();
					});
				});
				describe("that is our timemachine", function() {
					beforeEach( function() {
						spyOn( view, "_getNodeView" );
					});
					
					describe("if it has 1  (or less) children", function() {
						beforeEach( function() {
							node = {
								parent : {
									children : [ 1 ],
								},
							};
							ret = view._onNodeAdd(model, node);
						});

						it("should have gotten the node view for the node", function() {
							expect( view._getNodeView ).toHaveBeenCalledWith( node );
						});

						it("should have selected the current node", function() {
							expect( view.selectNode ).toHaveBeenCalledWith( model.current );
						});

						it("should have returned true", function() {
							expect( ret ).toBeTruthy();
						});
					});

					describe("if it has more than 1 child", function() {
						beforeEach( function() {
							node = {
								parent : {
									children : [ 1,2,3],
								},
							};
							spyOn( view, "_drawContents" );
							ret = view._onNodeAdd(model, node);
						});

						it("should have redrawn the contents", function() {
							expect( view._drawContents ).toHaveBeenCalled();
						});

						it("should have returned true", function() {
							expect( ret ).toBeTruthy();
						});
					});

				});
			});

			describe("when the root has been set", function() {
				describe("if the tree is not our timemachine", function() {
					beforeEach( function() {
						tree = {};
						node = {};
						spyOn( view, "_drawContents" );
						ret = view._onRootSet( tree, node );
					});

					it("should have returned false", function() {
						expect( ret ).toBeFalsy();
					});
				});
				
				describe("if the tree is our timemachine", function() {
					beforeEach( function() {
						node = {};
						spyOn( view, "_drawContents" );
						ret = view._onRootSet( model, node );
					});

					it("should have redrawn the contents", function() {
						expect( view._drawContents ).toHaveBeenCalled();
					});

					it("should have returned true", function() {
						expect( ret ).toBeTruthy();
					});
				});
			});

			describe("when a branching occurs", function() {
				beforeEach( function() {
					spyOn( view, "_drawContents" );
					view._onBranch();
				});

				it("should have redrawn the contents", function() {
					expect( view._drawContents ).toHaveBeenCalled();
				});
			});

			describe("when selecting a node", function() {
				describe("when the node is in our nodes", function() {
					beforeEach( function() {
						node = {
							id : 1,
						};
						view._rows[1] = node;
						view.selectNode( node );
					});
				});

				xdescribe("when the node has no alternatives", function() {
					beforeEach( function() {
						node = {
						}

						spyOn( view, "_hideButtons" );
						view.selectNode( node );
					});

					it("should have hidden the buttons", function() {
						expect( view._hideButtons ).toHaveBeenCalled();
					});
				});

				xdescribe("when the node has alternatives", function() {
					beforeEach( function() {
						node = {
							parent: {
								children : [1,2,3]
							}
						}

						spyOn( view, "_showButtons" );
						view.selectNode( node );
					});

					it("should have shown the buttons", function() {
						expect( view._showButtons ).toHaveBeenCalled();
					});
				});

			});

			xdescribe("when setting a node to active", function() {
				beforeEach( function() {
					node = {
						id : 1,
					};
					view._rows[1] = node;
					view.setActive( node );
				});

				it("should have added the active class", function() {
					
				});
			});
		});

		describe("when getting the tree view of a node", function() {
			describe("when the node has no branch", function() {
				beforeEach( function() {
					node = {
					};
					spyOn( view, "_getNodeView" );
					spyOn( view, "_getTreeView" ).andCallThrough();
					treeView = view._getTreeView(node);
				});

				it("should have gotten the node view for the node", function() {
					expect( view._getNodeView ).toHaveBeenCalledWith( node );
				});

				it("should not have gotten the tree view for that branch", function() {
					expect( view._getTreeView.callCount ).toBe( 1 );
				});
			});
		});

		describe("when getting the tree view of a node", function() {
			describe("when the node has a branch", function() {
				beforeEach( function() {
					node = {
						branch: {},
					};
					spyOn( view, "_getNodeView" );
					spyOn( view, "_getTreeView" ).andCallThrough();
					treeView = view._getTreeView(node);
				});

				it("should have gotten the node view for the node", function() {
					expect( view._getNodeView ).toHaveBeenCalledWith( node );
				});

				it("should have gotten the tree view for that branch", function() {
					expect( view._getTreeView.callCount ).toBe( 2 );
				});
			});
		});

		xdescribe("when getting the node view of a node", function() {
			describe("of a node with an action", function() {
				beforeEach( function() {
					//Test stub
				});
			});
		});

		describe("when setting the tree of the view", function() {
			beforeEach( function() {
				newTree = {};
				spyOn( view, "_drawContents" );
				view.setTree( newTree );
			});

			it("should have set the tree", function() {
				expect( view.timemachine ).toBe( newTree );
			});

			it("should have redrawn the contents", function() {
				expect( view._drawContents ).toHaveBeenCalled();
			});
		});
	});
});
