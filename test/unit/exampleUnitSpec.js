define([/*insert dependencies here*/], function() {

  describe('My first test', function() {
//    var $compile, $rootScope;

    //Require the module
//    beforeEach(module('myApp'));

//    beforeEach(inject(function (_$compile_, _$rootScope_) {
//      $compile = _$compile_;
//      $rootScope = _$rootScope_;
//    }));

    //var assert = require("assert")
    describe('Array', function(){
      describe('#indexOf()', function(){
        it('should return -1 when the value is not present', function(){
         // expect([1,2,3].indexOf(5)).toBe(-1);
          expect([1,2,3].indexOf(0)).toBe(-1);
        //assert.equal(-1, [1,2,3].indexOf(5));
        //assert.equal(-1, [1,2,3].indexOf(0));
        });
      });
    });

    describe('Array2', function(){
      describe('#indexOf()', function(){
        it('should return -1 when the value is not present', function(){
         // expect([1,2,3].indexOf(5)).toBe(-1);
          expect([1,2,3].indexOf(1)).toBe(0);
        //assert.equal(-1, [1,2,3].indexOf(5));
        //assert.equal(-1, [1,2,3].indexOf(0));
        });
      });
    });


  });

});