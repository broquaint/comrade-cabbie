extends Sprite

func _ready():
	set_region(true)
	set_meter()
	
func set_meter():
	var ts = texture.get_size()
	var new_height = ts.y * (GameState.satisfaction/100)
	set_region_rect(Rect2(0, ts.y-new_height, ts.x, new_height))

func on_new_dropoff(dropoff, travel_time, travel_score):
	# Should ensure the satisfaction value is in its final state
	call_deferred('set_meter')
