extends TileMap

signal announce_unlock(msg)
func _ready():
	connect('announce_unlock', $'/root/Root/HUD/MessageLog', 'on_message')

func on_asteroid_unlocked(asteroid):
	if asteroid == 'Services':
		$AnimationPlayer.play("LiftServicesBarrier")
		emit_signal("announce_unlock", 'The Services asteroid is interested in your services, head to the east tunnel')
