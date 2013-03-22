describe("Module", function() {
    var module;
    
    beforeEach(function() {
        module = new Module('DNA', '1*2*3*4*3');
    });
    
    it("should be able to store the module type", function() {
        expect(module.type).toEqual('DNA');
    });
    
    it("should be able to store the module equation", function() {
        expect(module.equation).toEqual('1*2*3*4*3');
    });
});