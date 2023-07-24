extends KinematicBody2D

const THRUST : float = 12.0
const MAX_SPEED : float = 600.0
const ROTATION_SPEED : float = 6.0 * 60

signal picking_up(current_pickup)
signal new_pickup(current_dropoff)
signal new_dropoff()
signal compass_update(direction, type)

var velocity : Vector2
var current_pickup : Area2D
var current_dropoff : Area2D

func _process(_delta):
	var compass_type = 'dropoff' if current_dropoff != null else 'pickup'
	emit_signal('compass_update', calc_compass(), compass_type)

func _physics_process(delta):
	if Input.is_action_pressed("move_left"):
		rotation_degrees -= delta * ROTATION_SPEED
	elif Input.is_action_pressed("move_right"):
		rotation_degrees += delta * ROTATION_SPEED

	# get acceleration if thrust is pressed
	if Input.is_action_pressed("move_up"):
		var acceleration : Vector2

		# -THRUST because vector pointing up = y value of -1, and
		# rotated() method of Vector2 needs a radian, not degrees,
		# so convert that using deg2rad
		acceleration = Vector2(0, -THRUST).rotated(deg2rad(rotation_degrees))

		# add acceleration to current speed
		velocity += acceleration

	# dampen a bit
	velocity *= 0.98

	# cap speed
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
		# velocity vector is added to position in BaseObject.gd

	velocity = move_and_slide(velocity)

func set_next_pickup():
	current_pickup = find_nearest_pickup()
	current_pickup.get_node('AnimationPlayer').play('Pulse')
	current_pickup.get_node('Point Pulse').visible = true
	emit_signal("picking_up", current_pickup)

func set_next_dropoff():
	current_pickup.get_node('AnimationPlayer').stop()
	current_pickup.get_node('Point Pulse').visible = false
	var dropoffs = get_parent().dropoffs
	current_dropoff = dropoffs[randi() % dropoffs.size()]
	current_dropoff.get_node('AnimationPlayer').play('Pulse')
	current_dropoff.get_node('Point Pulse').visible = true
	emit_signal('new_pickup', current_dropoff)

func find_nearest_pickup() -> Area2D:
	var pickups = get_parent().pickups
	var closest = pickups[0]
	for pickup in pickups:
		var dist = self.position.distance_to(pickup.position)
		if dist < self.position.distance_to(closest.position):
			closest = pickup
	return closest

func calc_compass():
	var point = current_dropoff if current_dropoff != null else current_pickup
	var diff = self.position - point.position
	var is_v = abs(diff.y) > abs(diff.x)
	if is_v:
		return 'north' if diff.y > 0 else 'south' 
	else	:
		return 'west' if diff.x > 0 else 'east'

func pickup_point_entered(_node, point):
	if current_dropoff == null:
		set_next_dropoff()
		current_pickup = null

func dropoff_point_entered(_node, point):
	# print('entered dropoff', point, ' current dropoff is ', current_dropoff)
	if point == current_dropoff:
		# Not in use at the moment.
		emit_signal('new_dropoff')
		current_dropoff.get_node('AnimationPlayer').stop()
		current_dropoff.get_node('Point Pulse').visible = false
		current_dropoff = null
		# This maybe doesn't want to be instant?
		set_next_pickup()
