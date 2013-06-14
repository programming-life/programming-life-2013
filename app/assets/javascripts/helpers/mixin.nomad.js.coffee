# Mixin for classes that allow dynamic properties
#
# @mixin
#
Mixin.Nomad =

	ClassMethods: {}
		
	
	InstanceMethods:

		RepelDistance: 200
		RepelForce: 4

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

		yolo: ( ) ->

			@startMigration()

			for i in [0...5]
				@doMigrationLogic()
				@doMigrationPhysics()

			@finishMigration()

		_drag: .1
		

		startMigration: ( ) ->			
			@location = new Point(@x, @y)
			@_momentum = new Vector(0, 0)
			@_forces = []

			view.startMigration() for view in @_views

		doMigrationLogic: ( ) ->
			@_momentum = new Vector(0, 0)

			for view in @_views
				for otherView in @_views
					unless view is otherView
						distance = view.location.distance(otherView.location)
						
						if distance < @RepelDistance
							fraction = 1 - distance / @RepelDistance

							magnitude = @RepelForce
							direction = view.location.direction(otherView)
							force = new Vector(magnitude, direction).multiply(fraction)

							otherView.addForce(force)

			view.doMigrationLogic() for view in @_views


		doMigrationPhysics: ( dt = 5 ) ->

			while force = @_forces.pop()
				@applyForce(force)

			@_momentum = @_momentum.multiply(1 - @_drag)

			dx = @_momentum.magnitude * Math.cos(@_momentum.direction) * dt
			dy = @_momentum.magnitude * Math.sin(@_momentum.direction) * dt

			console.log @, @location.x, dx, @location.y, dy

			x = @location.x + dx
			y = @location.y + dy
			@location = new Point(x, y)

			view.doMigrationPhysics(dt) for view in @_views

		finishMigration: ( ) ->
			view.finishMigration() for view in @_views
			#console.log @x, @y, @location.x, @location.y
			@moveTo(@location.x, @location.y, on)

		addForce: ( force ) ->
			@_forces.push(force)

		applyForce: ( force ) ->
			@_momentum = @_momentum.add(force)

