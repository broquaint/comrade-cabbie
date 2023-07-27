extends Sprite

export(Texture) var pickup
export(Texture) var dropoff

var direction_degrees = {
	'north': 0,
	'east': 90,
	'south': 180,
	'west': 270
}

func on_compass_update(direction : String, type: String):
	texture = pickup if type == 'pickup' else dropoff
	$"../../NeedleAnimationPlayer".play("NeedlePulse")
	rotation_degrees = direction_degrees[direction]
