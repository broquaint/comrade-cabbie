extends Sprite

var orig_pos : Vector2

func _ready():
	orig_pos = position
	set_region(true)
	set_meter()
#	var sb = StyleBoxFlat.new()
#	sb.bg_color = Color("#c8595652")
#	$"../MeterLabel".add_stylebox_override("normal", sb)
#	var sb2 = StyleBoxFlat.new()
#	sb2.bg_color = Color("#c8595652")
#	$"../MeterValue".add_stylebox_override("normal", sb2)
	
func set_meter():
	var ts = texture.get_size()
	var new_height = ts.y * (GameState.satisfaction/100)
	var offset     = ts.y - new_height
	set_region_rect(Rect2(0, offset, ts.x, new_height))
	position.y = orig_pos.y + offset/2

	$"../MeterValue".text = "%.2f%%" % GameState.satisfaction

func on_new_dropoff(dropoff, travel_time, travel_score):
	# Should ensure the satisfaction value is in its final state
	call_deferred('set_meter')
