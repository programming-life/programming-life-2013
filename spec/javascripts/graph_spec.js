describe("Graph", function() {
    var graph;
	var name = "test_graph";
    var data = [1, 3, 5, 5, 4, 8, 6, 3, 4, 1, 2, 6, 3];
	var data2 = [2, 5, 2, 3,1, 8, 5, 7, 6, 3, 2, 4, 3];
		
    var options = { dt: 1 };
    
	beforeEach(function() {
		graph = new Graph( name, options );
	});
	
	describe("when dataset is provided during creation", function() {
	
		beforeEach( function() {
			graph = new Graph( name, options, data );
		});
		
		it("should have 1 dataset", function() {
			expect( graph._datasets.length ).toEqual( 1 );
		});
    
		it("should have as many data points as data entries", function() {
			expect( graph._nPoints ).toEqual( data.length );
		});
    
		it("should keep all input data", function() {
			expect( graph._datasets[0].data ).toBe( data );
		});
		
		describe("when another dataset is added", function() {
			beforeEach( function() {
				graph.addData( data2 );
			});
			
			it("should have 2 datasets", function() {
				expect( graph._datasets.length ).toEqual( 2 );
			});
		});
	})
	    
	describe("when a dataset is added after creation", function() {
		
		beforeEach( function() {
    		graph.addData( data );
    	});
		
		it("should have 1 dataset", function() {
			expect( graph._datasets.length ).toEqual( 1 );
		});
		
		describe("when another dataset is added", function() {
			beforeEach( function() {
				graph.addData( data2 );
			});
			
			it("should have 2 datasets", function() {
				expect( graph._datasets.length ).toEqual( 2 );
			});
		});
	});
	
	describe("when a dataset is rendered", function() {
		var result, initial;
		
		beforeEach( function() {
    		graph.addData( data );
			initial = graph.getCanvas().clone();
			result = graph.render();
    	});
		
		it("should have rendered that on canvas", function() {
			expect( result ).not.toEqual( initial );
		});
		
		it("should returned a jQuery object as canvas", function() {    	
			expect( graph.getCanvas() instanceof $ );
			expect( result instanceof $ );
		});
	});
    
    describe("when the graph is cleared", function() {
    	beforeEach(function() {
			graph.addData( data );
    		graph.clear();
    	});
    	
    	it("should have no more datasets", function() {
    		expect( graph._datasets.length ).toEqual( 0 );
    	});
    	
    	it("should have 0 data points", function() {
    		expect( graph._nPoints ).toEqual( 0 );
    	});
    }); 
});