describe("Module", function() {
    var module;
    var args = new Array();
    args['type'] = 'DNA';
    //args['function'] = ''
    
    beforeEach(function() {
        module = new Module(args);
    });
    
    it("should be able to store the module type", function() {
        expect(module.type).toEqual('DNA');
    });
    
    //it("should be able to store the function type", function() {
    //    expect(module.function).toEqual('')
    //});
});