extends "res://Asteroid.gd"

func on_asteroid_unlocked(asteroid):
	# TODO – Create Fun asteroid and unlock _that_ too.
	if asteroid == 'Home':
		lift_barrier()
#		emit_signal("announce_unlock", '[b]The Fun asteroid wants you! Head to the [i]Mideastern Tunnel[/i]![/b]')
		emit_signal("announce_unlock", '[b]All asteroids explored! Comrade Cabbie, you are [i]the best![/i][/b]')

func lift_barrier():
	$HomeBarrier/AnimationPlayer.play("LiftHomeBarrier")
