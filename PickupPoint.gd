extends "res://DestPoint.gd"

class_name PickupPoint

func point_entered(player):
	emit_signal('pickup_entered', self)
	if player.picking_up():
		$Timer.start()
		$ProgressMeter.show()
		$AnimationPlayer.stop()
		$PointPulse.hide()
		$ProgressAnimation.play('ProgressFill')

func point_exited(player):
	.base_point_exited()
	if player.picking_up():
		$AnimationPlayer.play("Pulse")
		$PointPulse.show()
