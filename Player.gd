extends KinematicBody2D

const THRUST : float = 12.0
const MAX_SPEED : float = 600.0
const ROTATION_SPEED : float = 6.0 * 60

signal new_pickup(current_dropoff)
signal new_dropoff()
signal compass_update(direction)

var velocity : Vector2
var current_dropoff : Area2D

func _process(_delta):
	if current_dropoff != null:
		emit_signal('compass_update', calc_compass())

func _physics_process(delta) -> void:
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

func calc_compass():
	var diff = self.position - current_dropoff.position
	var is_v = abs(diff.y) > abs(diff.x)
	if is_v:
		return 'north' if diff.y > 0 else 'south' 
	else	:
		return 'west' if diff.x > 0 else 'east'

func pickup_point_entered(_node, point):
	print('entered pickup', point)
	var dropoffs = get_parent().dropoffs
	if current_dropoff == null:
		current_dropoff = dropoffs[randi() % dropoffs.size()]
		emit_signal('new_pickup', current_dropoff)
		emit_signal('compass_update', calc_compass())

func dropoff_point_entered(_node, point):
	print('entered dropoff', point, ' current dropoff is ', current_dropoff)
	if point == current_dropoff:
		emit_signal('new_dropoff')
		current_dropoff = null
		emit_signal('compass_update', 'none')
