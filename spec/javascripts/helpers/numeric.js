beforeEach(function() {

	this.addMatchers({

		toBeAtMost: function( expected ) {
			var actual = this.actual;
			var notText = this.isNot ? " not" : "";

			this.message = function () {
				return "Expected " + actual + notText + " to be at most " + expected;
			};

			return actual <= expected;
		},
	
		toBeAtLeast: function( expected ) {
			var actual = this.actual;
			var notText = this.isNot ? " not" : "";

			this.message = function () {
				return "Expected " + actual + notText + " to be at least " + expected;
			};

			return actual >= expected;
		},
		
		toBeBetween: function ( rangeFloor, rangeCeiling, inclusive ) {  
			
			if ( inclusive === undefined )
				inclusive = false
				
            if (rangeFloor > rangeCeiling) {  
                var temp = rangeFloor;  
                rangeFloor = rangeCeiling;  
                rangeCeiling = temp;  
            }  
			
            return ( this.actual > rangeFloor && this.actual < rangeCeiling ) || ( inclusive && this.actual == rangeFloor ) 
        }  
		
	});
});