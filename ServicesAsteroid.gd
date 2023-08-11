extends TileMap

signal announce_unlock(msg)
func _ready():
	connect('announce_unlock', $'/root/Root/HUD/MessageLog', 'on_message')

func on_asteroid_unlocked(asteroid):
	if asteroid == 'Study':
		$AnimationPlayer.play("LiftStudyBarrier")
		emit_signal("announce_unlock", 'The Study asteroid is interested in your services, head to the southern tunnel')
