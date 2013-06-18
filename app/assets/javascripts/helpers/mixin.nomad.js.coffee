# Mixin for classes that allow dynamic properties
#
# @mixin
#
Mixin.Nomad =

	ClassMethods: {}
		
	
	InstanceMethods:

		# RepelDistance: 200
		# RepelForce: 3
		# _drag: .1

		repelForce: 60
		repelDistance: 120
		_drag: .2

		included: ( ) ->


		Vector: class Vector
			constructor: ( @magnitude, @direction)  ->

			add: ( other ) ->
				x1 = @magnitude * Math.cos(@direction)
				y1 = @magnitude * Math.sin(@direction)

				x2 = other.magnitude * Math.cos(other.direction)
				y2 = other.magnitude * Math.sin(other.direction)

				x = x1 + x2
				y = y1 + y2

				magnitude = Math.sqrt(x * x + y * y)
				direction = Math.atan2(y, x)

				res = new Vector(magnitude, direction)
				return res

			multiply: ( scalar ) ->
				magnitude = @magnitude * scalar

				return new Vector(magnitude, @direction)

		Point: class Point
			constructor: ( @x, @y ) ->

			distance: ( other ) ->
				dx = other.x - @x
				dy = other.y - @y

				distance = Math.sqrt(dx * dx + dy * dy)
				return distance

			direction: ( other ) ->
				dx = other.x - @x
				dy = other.y - @y

				direction = Math.atan2(dy, dx)
				return direction

			to: ( other ) ->
				distance = @distance(other)
				direction = @direction(other)

				return new Vector(distance, direction)

		distance: ( other ) ->
			return @migrationLocation.distance(other.migrationLocation)

		direction: ( other ) ->
			return @migrationLocation.direction(other.migrationLocation)

		to: ( other ) ->
			return @migrationLocation.to(other.migrationLocation)

		migrate: ( ) ->
			window.yoloStartTime = Date.now()
			console.log 'migrate', @type, Date.now() - window.yoloStartTime
			@startMigration()

			iterations = 400

			for i in [0...iterations]
				_.defer( => 
					@doMigrationLogic()
					@doMigrationPhysics()
				)

			_.defer( => @finishMigration())

		startMigration: ( ) ->
			console.log 'start', @type, Date.now() - window.yoloStartTime
			@migrationLocation = new @Point(@x, @y)			
			@_forces = []

			view.startMigration() for view in @_views

		doMigrationLogic: ( ) ->
			#console.log 'logic', @type, Date.now() - window.yoloStartTime
			view.doMigrationLogic() for view in @_views

		doMigrationPhysics: ( dt = .1 ) ->
			#console.log 'physics', @type, Date.now() - window.yoloStartTime
			@migrationMomentum = new @Vector(0, 0)

			while force = @_forces.pop()
				@_applyForce(force)

			@migrationMomentum = @migrationMomentum.multiply(1 - @_drag)

			dx = @migrationMomentum.magnitude * Math.cos(@migrationMomentum.direction) * dt
			dy = @migrationMomentum.magnitude * Math.sin(@migrationMomentum.direction) * dt

			x = @migrationLocation.x + dx
			y = @migrationLocation.y + dy

			@migrationLocation = new @Point(x, y)
			@_forces = []

			view.doMigrationPhysics(dt) for view in @_views

		finishMigration: ( ) ->
			@moveTo(@migrationLocation.x, @migrationLocation.y, on)
			
			for view in @_views
				( ( view ) ->
					_.defer( -> view.finishMigration() )
				) view

			console.log 'finish', @type, Date.now() - window.yoloStartTime

		addForce: ( force ) ->
			@_forces.push(force)

		_applyForce: ( force ) ->
			@migrationMomentum = @migrationMomentum.add(force)


		# migrate: ( ) ->

		# 	@startMigration()

		# 	for i in [0...5000]
		# 		@doMigrationLogic()
		# 		@doMigrationPhysics()

		# 	@finishMigration()		

		# startMigration: ( ) ->			
		# 	@location = new Point(@x, @y)
		# 	@_momentum = new Vector(0, 0)
		# 	@_forces = []

		# 	view.startMigration() for view in @_views

		# doMigrationLogic: ( ) ->
		# 	@_momentum = new Vector(0, 0)

		# 	for view in @_views
		# 		for otherView in @_views
		# 			unless view is otherView
		# 				distance = view.location.distance(otherView.location)
						
		# 				if distance < @RepelDistance
		# 					fraction = 1 - distance / @RepelDistance

		# 					magnitude = @RepelForce
		# 					direction = view.location.direction(otherView)
		# 					force = new Vector(magnitude, direction).multiply(fraction)

		# 					otherView.addForce(force)

		# 	view.doMigrationLogic() for view in @_views


		# doMigrationPhysics: ( dt = 5 ) ->

		# 	while force = @_forces.pop()
		# 		@applyForce(force)

		# 	@_momentum = @_momentum.multiply(1 - @_drag)

		# 	dx = @_momentum.magnitude * Math.cos(@_momentum.direction) * dt
		# 	dy = @_momentum.magnitude * Math.sin(@_momentum.direction) * dt

		# 	x = @location.x + dx
		# 	y = @location.y + dy
		# 	@location = new Point(x, y)

		# 	view.doMigrationPhysics(dt) for view in @_views

		# finishMigration: ( ) ->
		# 	view.finishMigration() for view in @_views
		# 	@moveTo(@location.x, @location.y, on)

		# addForce: ( force ) ->
		# 	@_forces.push(force)

		# applyForce: ( force ) ->
		# 	@_momentum = @_momentum.add(force)

