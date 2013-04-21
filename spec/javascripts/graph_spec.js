describe("Graph", function() {
    var graph;
	var name = "test_graph";
    var data = [1, 3, 5, 5,4, 8, 6, 3, 4, 1, 2, 6, 3];
    window.dt = 0.1;
    
    beforeEach(function() {
        graph = new Graph(name, data);
    });
    
    it("should have one initial dataset when one is provided", function() {
        expect(graph._datasets.length).toEqual(1);
    });
    
    it("should have as many data points as data entries", function() {
    	expect(graph._nPoints).toEqual(data.length);
    });
    
    it("should keep all input data", function() {
    	expect(graph._datasets[0]).toBe(data);
    });
    
    it("should have a different rendered graph from empty graph", function() {
    	var gc = graph.getCanvas().clone();
    	expect(graph.render()).not.toEqual(gc);
    });
    
    it("should return a jQuery object as canvas", function() {    	
    	expect(graph.getCanvas() instanceof $);
    	expect(graph.render() instanceof $);
    });
    
	describe("when the a dataset is added", function() {
		var data2 = [2, 5, 2, 3,1, 8, 5, 7, 6, 3, 2, 4, 3];
		
		beforeEach(function() {
    		graph.addData( data2 );
    	});
		
		it("should have two datasets", function() {
			expect( graph._datasets.length ).toEqual( 2 );
		});
	});
    
    describe("when the graph is cleared", function() {
    	beforeEach(function() {
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
