extends KinematicBody2D

# https://kidscancode.org/godot_recipes/3.x/2d/topdown_movement/index.html

var speed = 200
var rotation_speed = 1.5

var velocity = Vector2.ZERO
var rotation_dir = 0

func get_input():
	rotation_dir = 0
	velocity = Vector2.ZERO
	if Input.is_action_pressed('move_right'):
		rotation_dir += 1
	if Input.is_action_pressed('move_left'):
		rotation_dir -= 1
	if Input.is_action_pressed('move_down'):
		velocity -= transform.x * speed
	if Input.is_action_pressed('move_up'):
		velocity += transform.x * speed

func _physics_process(delta):
	get_input()
	rotation += rotation_dir * rotation_speed * delta
	velocity = move_and_slide(velocity)
