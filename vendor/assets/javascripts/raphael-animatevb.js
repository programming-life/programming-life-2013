Raphael.fn.animateViewBox = function animateViewBox( x, y, w, h, duration, easing_function, callback ) {
	var cx = this._viewBox ? this._viewBox[0] : 0,
		dx = x - cx,
		cy = this._viewBox ? this._viewBox[1] : 0,
		dy = y - cy,
		cw = this._viewBox ? this._viewBox[2] : this.width,
		dw = w - cw,
		ch = this._viewBox ? this._viewBox[3] : this.height,
		dh = h - ch,
		self = this;;
	easing_function = easing_function || "linear";

	var interval = 25;
	var steps = duration / interval;
	var current_step = 0;
	var easing_formula = Raphael.easing_formulas[easing_function];

	var intervalID = setInterval( function()
		{
			var ratio = current_step / steps;
			_.defer( self.setViewBox( cx + dx * easing_formula( ratio ),
							 cy + dy * easing_formula( ratio ),
							 cw + dw * easing_formula( ratio ),
							 ch + dh * easing_formula( ratio ), false )
			);
			if ( current_step++ >= steps )
			{
				clearInterval( intervalID );
				callback && _.defer( callback() );
			}
		}, interval );
}
