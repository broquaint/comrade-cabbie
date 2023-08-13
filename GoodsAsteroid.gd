extends TileMap

signal announce_unlock(msg)

func on_asteroid_unlocked(asteroid):
	# TODO – Create Fun asteroid and unlock _that_ too.
	if asteroid == 'Home':
		$HomeBarrier/AnimationPlayer.play("LiftHomeBarrier")
#		emit_signal("announce_unlock", '[b]The Fun asteroid wants you! Head to the [i]Mideastern Tunnel[/i]![/b]')
		emit_signal("announce_unlock", '[b]All asteroids explored! Comrade Cabbie, you are [i]the best![/i][/b]')
