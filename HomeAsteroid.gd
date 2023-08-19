extends "res://Asteroid.gd"

func on_asteroid_unlocked(asteroid):
	if asteroid == 'Services':
		lift_barrier()
		emit_signal('announce_unlock', '[b]The Services asteroid wants you! Head to the [i]East tunnel[/i]![/b]')

func lift_barrier():
	$ServicesBarrier/AnimationPlayer.play("LiftServicesBarrier")
