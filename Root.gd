extends Node2D

var pickups : Array = []
var dropoffs : Array = []

var community_satisfaction = 75

func _ready():
	randomize()

	$Player.position = Vector2(2000, 1000)

	_build_points()

	$Player.connect('picking_up',  GameState, 'on_picking_up')
	$Player.connect('new_pickup',  GameState, 'on_new_pickup')
	$Player.connect('new_dropoff', GameState, 'on_new_dropoff')
	
	$Player.connect('picking_up', $HUD/Control, 'on_picking_up')
	$Player.connect('new_pickup', $HUD/Control, 'on_new_pickup')
	$Player.connect('new_pickup', $HUD/DestFlashControl, 'on_new_pickup')
	$Player.connect('new_dropoff', $HUD/DestFlashControl, 'on_new_dropoff')
	$Player.connect('new_dropoff', $HUD/SatisfactionMeter, 'on_new_dropoff')
	$Player.connect('distance_update', $HUD/Compass, 'on_distance_update')
	$Player.connect('travel_time_update', $HUD/Control, 'on_travel_time_update')
	$Player.connect('compass_update', $HUD/Compass, 'on_compass_update')
	$Player.connect('compass_update', $HUD/Compass/Needle, 'on_compass_update')
	$Player.set_next_pickup()

func _build_points():
	for kid in get_children():
		if not("Asteroid" in kid.name):
			continue
		for point in kid.get_node('Pickups').get_children():
			pickups.append(point)
			point.connect('body_entered', $Player, 'pickup_point_entered', [point])
		for point in kid.get_node('Dropoffs').get_children():
			dropoffs.append(point)
			point.connect('body_entered', $Player, 'dropoff_point_entered', [point])
