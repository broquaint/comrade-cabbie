extends Node2D

var pickups : Array = []
var dropoffs : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	$Player.position = Vector2(2000, 1000)

	_build_points()

	$Player.connect('picking_up', $HUD/Control, 'on_picking_up')
	$Player.connect('new_pickup', $HUD/Control, 'on_new_pickup')
	$Player.connect('new_pickup', $HUD/DestFlashControl, 'on_new_pickup')
	$Player.connect('new_dropoff', $HUD/Control, 'on_new_dropoff')
	$Player.connect('distance_update', $HUD/Control, 'on_distance_update')
	$Player.connect('travel_time_update', $HUD/Control, 'on_travel_time_update')
	$Player.connect('compass_update', $HUD/Compass, 'on_compass_update')
	$Player.set_next_pickup()

func _build_points():
	for point in $"Home Asteroid".get_children():
		if point.is_in_group('pickup points'):
			pickups.append(point)
			#print("Added pickup point ", point.point_name)
			point.connect('body_entered', $Player, 'pickup_point_entered', [point])
		elif point.is_in_group('dropoff points'):
			dropoffs.append(point)
			#print("Added dropoff point ", point.point_name)
			point.connect('body_entered', $Player, 'dropoff_point_entered', [point])
