extends KinematicBody2D

const THRUST : float = 10.0
const MAX_SPEED : float = 400.0
const ROTATION_SPEED : float = 5.0 * 60

signal new_pickup(current_dropoff)
signal new_dropoff()

var dead : bool
var velocity : Vector2
var current_dropoff : Node

func _physics_process(delta) -> void:
	if dead == true:
		return

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

func pickup_point_entered(_node, point):
	print('entered pickup', point)
	var dropoffs = get_parent().dropoffs
	current_dropoff = dropoffs[randi() % dropoffs.size()]
	emit_signal('new_pickup', current_dropoff)

func dropoff_point_entered(_node, point):
	print('entered dropoff', point, ' current dropoff is ', current_dropoff)
	if point == current_dropoff:
		emit_signal('new_dropoff')
		current_dropoff = null
