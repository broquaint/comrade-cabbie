extends "res://Asteroid.gd"

func on_asteroid_unlocked(asteroid):
	if asteroid == 'Goods':
		$GoodsBarrier/AnimationPlayer.play("LiftGoodsBarrier")
		emit_signal("announce_unlock", '[b]The Goods asteroid wants you! Head to the [i]Western Tunnel[/i]![/b]')
