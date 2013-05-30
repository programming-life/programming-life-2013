numeric.defer = ( func, args... ) ->
	return setTimeout( ( () -> func.apply( undefined, args ) ), 1)

numeric.asynccancel = () ->
		running = on
		result = 
			cancel: () => running = off
		Object.defineProperty( result, 'cancelled',
			get: -> not running
		)
		return result
	
numeric.asyncdopri = 
	( x0, x1, y0, f, tol = 1e-6, maxit = 1000, event, token = numeric.asynccancel() ) ->
    
		# Initial values
		xs = [ x0 ]
		ys = [ y0 ]
		ymid = []
		h = ( x1 - x0 ) / 10
		
		# Butchers tableau
		A2 = 1/5
		A3 = [ 3/40, 9/40 ]
		A4 = [ 44/45, -56/15, 32/9 ]
		A5 = [ 19372/6561, -25360/2187, 64448/6561, -212/729 ]
		A6 = [ 9017/3168, -355/33, 46732/5247, 49/176, -5103/18656 ]
		b  = [ 35/384, 0, 500/1113, 125/192, -2187/6784, 11/84 ]
		
		bm = [ 0.5 * 6025192743 / 30085553152
			0
			0.5 * 51252292925 / 65400821598
			0.5 * -2691868925 / 45128329728
			0.5 * 187940372067 / 1594534317056
			0.5 * -1776094331 / 19743644256
			0.5 * 11237099 / 235043384 ]
		c = [ 1/5, 3/10, 4/5, 8/9, 1, 1 ]
		e = [ -71/57600, 0, 71/16695, -71/1920, 17253/339200, -22/525, 1/40 ]
		
		# Copy the numeric operators
		add = numeric.add
		mul = numeric.mul
		norminf = numeric.norminf
		any = numeric.any
		lt = numeric.lt
		numand = numeric.and
		sub = numeric.sub
		
		# Copy the Math operators
		max = Math.max
		min = Math.min
		abs = Math.abs
		pow = Math.pow
		
		# Result object
		k1 = [ f( x0, y0 ) ]
		ret = new numeric.Dopri( xs, ys, k1, ymid, -1, "" )
			
		i = 0
		it = 0

		# The expensive step
		dopristep = () =>
			it = it + 1
			h = x1 - x0 if x0 + h > x1
			
			# The first six stages
			k2 = f( x0 + c[ 0 ] * h, add( y0, mul( A2 * h, k1[ i ] ) ) )
			k3 = f( x0 + c[ 1 ] * h, add( add( y0, mul( A3[ 0 ] * h, k1[ i ] ) ), mul( A3[ 1 ] * h, k2 ) ) )
			k4 = f( x0 + c[ 2 ] * h, add( add( add( y0, mul( A4[ 0 ] * h, k1[ i ] ) ), mul( A4[ 1 ] * h, k2) ), mul( A4[ 2 ] * h, k3 ) ) )
			k5 = f( x0 + c[ 3 ] * h, add( add( add( add( y0, mul( A5[ 0 ] * h, k1[ i ] ) ), mul( A5[ 1 ] * h, k2) ), mul( A5[ 2 ] * h, k3) ), mul( A5[ 3 ] * h, k4 ) ) )
			k6 = f( x0 + c[ 4 ] * h, add( add( add( add( add( y0, mul( A6[ 0 ] * h, k1[ i ] ) ), mul( A6[ 1 ] * h, k2) ), mul( A6[ 2 ] * h, k3 ) ), mul( A6[ 3 ] * h, k4 ) ), mul( A6[ 4 ] * h, k5 ) ) )
			
			# The seventh and final stage
			y1 = add( add( add( add( add( y0, mul( k1[ i ], h * b[ 0 ] ) ), mul( k3, h * b[ 2 ] ) ), mul(k4, h * b[ 3 ] ) ), mul( k5, h * b[ 4 ] ) ), mul( k6, h * b[ 5 ] ) )
			k7 = f( x0 + h, y1 )
			
			# Error estimation
			er = add( add( add( add( add( mul( k1[ i ], h * e[ 0 ] ), mul( k3, h * e[ 2 ] ) ), mul( k4, h * e[ 3 ] ) ), mul( k5, h * e[ 4 ] ) ), mul( k6, h * e[ 5 ] ) ), mul( k7, h * e[ 6 ] ) )
			erinf = if typeof er is "number" then abs er else norminf er
			
			# Reject when tolerance ( min step size ) reached
			if erinf > tol
				h = 0.2 * h * pow( tol/erinf, 0.25 )
				
				# If we didn't find any new values for this step
				if x0 + h is x0
					ret.msg = "Step size became too small";
					return false
					
				return true
				
			# Mid values for estimation function
			ymid[ i ] = add( add( add( add( add( add( y0, mul( k1[ i ], h * bm[ 0 ] ) ), mul( k3 , h * bm[ 2 ] ) ), mul( k4, h * bm[ 3 ] ) ), mul( k5, h * bm[ 4 ] ) ), mul( k6, h * bm[ 5 ] ) ), mul( k7, h * bm[ 6 ] ) )
			
			# The iteration values
			i = i + 1
			xs[ i ] = x0 + h
			ys[ i ] = y1
			
			# Last step is first step value
			k1[ i ] = k7         

			# Check that event
			if event?
				xl = x0
				xr = x0 + 0.5 * h
				e1 = event( xr, ymid[ i - 1 ] )
				ev = numand( lt( e0, 0 ), lt( 0, e1 ) )
				if not any ev
					xl = xr
					xr = x0 + h
					e0 = e1
					e1 = event( xr, y1 )
					ev = numand( lt( e0, 0 ), lt( 0, e1 ) )
				if any ev
					side = 0
					sl = 1.0
					sr = 1.0
					while on
						if _( e0 ).isNumber() 
							xi = ( sr * e1 * xl - sl * e0 *xr )/( sr * e1 - sl * e0 )
						else
							xi = xr
							for j in [e0.length...-1] 
								if e0[ j ] < 0 and e1[ j ] > 0 
									xi = min( xi, ( sr * e1[ j ] * xl - sl * e0[ j ] * xr )/( sr * e1[ j ] - sl * e0[ j ] ) )
                    
						break if xi <= xl or xi >= xr
						yi = ret._at( xi, i - 1 )
						ei = event( xi, yi )
						en = numand( lt( e0, 0 ), lt( 0,ei ) )
						if any en
							xr = xi
							e1 = ei
							ev = en
							sr = 1.0
							if side is -1 
								sl *= 0.5
							else 
								sl = 1.0
							side = -1
						else
							xl = xi
							e0 = ei
							sl = 1.0
							if side is 1 
								sr *= 0.5
							else 
								sr = 1.0
							side = 1;
					
					y1 = ret._at( 0.5 * ( x0 + xi ), i - 1 )
					ret.f[ i ] = f( xi, yi )
					ret.x[ i ] = xi
					ret.y[ i ] = yi
					ret.ymid[ i - 1 ] = y1
					ret.events = ev
					ret.iterations = it
					return false
					
			x0 = x0 + h
			y0 = y1
			h  = min( 0.8 * h * pow( tol / erinf, 0.25 ), 4 * h )
			return true
			
		# The asyncloop
		dopriloop = ( ) =>
			#console.log "loop enter #{x0} < #{x1} and #{it} < #{maxit}"
			
			# While looping
			if x0 < x1 and it < maxit
			
				# Defer the next step
				numeric.defer () => 
					promise.notify( Math.max( x0 / x1, it / maxit ) )
					if dopristep() and not token.cancelled
						dopriloop() 
					else
						ret.msg = 'cancelled' if token.cancelled
						ret.iterations = it
						promise.reject ret
						
				return
			
			# When done
			done = () =>
				promise.notify( Math.max( x0 / x1, it / maxit ) )
				#console.log "loop end #{it}"
				ret.iterations = it
				promise.resolve ret
				
			numeric.defer done
			return
			
		promise = $.Deferred dopriloop
		console.log "after create"
		
		return promise.promise()