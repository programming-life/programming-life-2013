describe("Module", function() {
    var module;
    var args = new Array();
    args['type'] = 'DNA';
    args['equation'] = '1*2*3*4*3';
    
    beforeEach(function() {
        module = new Module(args);
    });
    
    it("should be able to store the module type", function() {
        expect(module.type).toEqual('DNA');
    });
    
    it("should be able to store the module equation", function() {
        expect(module.equation).toEqual('1*2*3*4*3');
    });
});