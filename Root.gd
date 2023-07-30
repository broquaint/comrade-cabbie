extends Node2D

var asteroids = {}
var pickups   = {}
var dropoffs  = {}

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
	$Player.set_next_pickup($HomeAsteroid)
	
	$HomeAsteroid/MajorPaths/Sprite2/Boost1.connect('body_entered', $Player, 'boost_entered')
	$HomeAsteroid/MajorPaths/Sprite2/Boost2.connect('body_entered', $Player, 'boost_entered')
	$HomeAsteroid/MajorPaths/Sprite2/Boost3.connect('body_entered', $Player, 'boost_entered')
	$HomeAsteroid/MajorPaths/Sprite2/Boost4.connect('body_entered', $Player, 'boost_entered')

func _build_points():
	for kid in get_children():
		if "Asteroid" in kid.name:
			pickups[kid.name] = []
			dropoffs[kid.name] = []
			asteroids[kid.name] = kid
	for k in asteroids.keys():
		var v = asteroids[k]
		for point in v.get_node('Pickups').get_children():
			pickups[k].append(point)
			point.real_pos = point.position + v.position
			point.connect('body_entered', $Player, 'pickup_point_entered', [point, v])
		for point in v.get_node('Dropoffs').get_children():
			dropoffs[k].append(point)
			point.real_pos = point.position + v.position
			point.connect('body_entered', $Player, 'dropoff_point_entered', [point, v])
