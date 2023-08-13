extends TileMap

signal announce_unlock(msg)

func on_asteroid_unlocked(asteroid):
	if asteroid == 'Services':
		$AnimationPlayer.play("LiftServicesBarrier")
		emit_signal('announce_unlock', '[b]The Services asteroid wants you! Head to the [i]East tunnel[/i]![/b]')
