;(function() {
  Raphael.fn.addGuides = function() {
    this.ca.guide = function(g) {
      return {
        guide: g
      };
    };
    this.ca.along = function(percent) {
      var g = this.attr("guide");
      var len = g.getTotalLength();
      var point = g.getPointAtLength(percent * len);
      var t = {
        transform: "t" + point.x + " " + point.y
      };
      return t;
    };
  };
})();