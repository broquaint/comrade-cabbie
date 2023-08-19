extends "res://Asteroid.gd"

func on_asteroid_unlocked(asteroid):
	if asteroid == 'Study':
		$StudyBarrier/AnimationPlayer.play("LiftStudyBarrier")
		emit_signal("announce_unlock", '[b]The Study asteroid wants you! Head to the [i]Southern Tunnel[/i]![/b]')
