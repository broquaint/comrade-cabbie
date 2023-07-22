extends Node2D

var pickups : Array = []
var dropoffs : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.position = Vector2(2000, 1000)
	_build_points()
	$Player.connect('new_pickup', $HUD/Control, 'on_new_pickup')
	$Player.connect('new_dropoff', $HUD/Control, 'on_new_dropoff')
	$Player.connect('compass_update', $HUD/Compass, 'on_compass_update')

func _build_points():
	for point in $"Home Asteroid".get_children():
		if point.is_in_group('pickup points'):
			pickups.append(point)
			print("Added pickup point ", point.point_name)
			point.connect('body_entered', $Player, 'pickup_point_entered', [point])
		elif point.is_in_group('dropoff points'):
			dropoffs.append(point)
			print("Added dropoff point ", point.point_name)
			point.connect('body_entered', $Player, 'dropoff_point_entered', [point])
