extends Control

var asteroid_orig_pos : Vector2
var overall_orig_pos  : Vector2

func _ready():
	asteroid_orig_pos = $AsteroidSatisfactionMeterSprite.position
	overall_orig_pos  = $SatisfactionMeterSprite.position
	$AsteroidSatisfactionMeterSprite.set_region(true)
	$SatisfactionMeterSprite.set_region(true)
	
func set_progress_meter():
	var meter      = $SatisfactionMeterSprite
	var ts         = meter.texture.get_size()
	var gjc        = GameState.good_journey_count()
	var unlock_pct = float(gjc) / GameState.UNLOCK_THRESHOLD if gjc > 0 else 0
	var new_height = ts.y * unlock_pct
	var offset     = ts.y - new_height
	meter.set_region_rect(Rect2(0, offset, ts.x, new_height))
	meter.position.y = overall_orig_pos.y + offset/2

func set_asteroid_meter(asteroid):
	var meter      = $AsteroidSatisfactionMeterSprite
	var ts         = meter.texture.get_size()
	var new_height = ts.y * (GameState.asteroid_satisfaction[asteroid.name] / 100)
	var offset     = ts.y - new_height
	meter.set_region_rect(Rect2(0, offset, ts.x, new_height))
	meter.position.y = asteroid_orig_pos.y + offset/2

	$AsteroidMeterValue.text = "%.2f%%" % GameState.asteroid_satisfaction[asteroid.name]
	$AsteroidMeterLabel.text = '%s Satisfaction' % asteroid.name.replace('Asteroid', '')

func on_asteroid_change(_node, tunnel: Tunnel):
	call_deferred('set_asteroid_meter', GameState.current_asteroid)

func on_new_dropoff(dropoff, asteroid, travel_time, travel_score):
	# Should ensure the satisfaction value is in its final state
	call_deferred('set_progress_meter')
	call_deferred('set_asteroid_meter', asteroid)
