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

    it("should be able to set a new module type", function() {
        module.type = 'Lipid';
        expect(module.type).toNotEqual('DNA');
        expect(module.type).toEqual('Lipid');
    });

    it("should be able to set a new module equation", function() {
        module.equation = '3*2-1';
        expect(module.equation).toNotEqual('1*2*3*4*3');
        expect(module.equation).toEqual('3*2-1');
    });
});