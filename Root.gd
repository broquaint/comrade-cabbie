extends Node2D

var pickups : Array = []
var dropoffs : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.position = Vector2(96, 96)
	_build_points()

func _build_points():
	for point in $TileMap.get_children():
		if point.is_in_group('pickup points'):
			pickups. append(point)
			point.connect('body_entered', $Player, 'pickup_point_entered')
		elif point.is_in_group('dropoff points'):
			dropoffs.append(point)
			point.connect('body_entered', $Player, 'dropoff_point_entered')
