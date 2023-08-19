extends "res://Asteroid.gd"

func on_asteroid_unlocked(asteroid):
	if asteroid == 'Study':
		lift_barrier()
		emit_signal("announce_unlock", '[b]The Study asteroid wants you! Head to the [i]Southern Tunnel[/i]![/b]')

func lift_barrier():
	$StudyBarrier/AnimationPlayer.play("LiftStudyBarrier")
