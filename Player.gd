extends KinematicBody2D

const THRUST : float = 10.0
const MAX_SPEED : float = 400.0
const ROTATION_SPEED : float = 5.0 * 60

var dead : bool
var velocity : Vector2

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

	#position += velocity * delta
	velocity = move_and_slide(velocity)

