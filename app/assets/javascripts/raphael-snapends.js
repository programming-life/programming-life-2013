original = Raphael.g.snapEnds
Raphael.g.snapEnds = function() {
	ret = original.apply(this, arguments);
	if (arguments[1] < ret.to) {
		ret.to = arguments[1];
	}
	return ret;
};
