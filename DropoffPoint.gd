extends "res://DestPoint.gd"

class_name DropoffPoint

func point_entered(player):
	if self == player.current_dropoff and player.dropping_off():
		$Timer.start()
		$ProgressMeter.show()
		$AnimationPlayer.stop()
		$PointPulse.hide()
		$ProgressAnimation.play('ProgressFill')

func point_exited(player):
	.base_point_exited()
	if self == player.current_dropoff and player.dropping_off():
		$AnimationPlayer.play("Pulse")
		$PointPulse.show()

func announce_msg(travel_distance):
	var in_asteroid = ''
	if get_asteroid() != GameState.current_asteroid:
		in_asteroid = ', [b]%s[/b],' % (get_asteroid().map_name + ' Asteroid')
	return 'Drop me off at [b]' + point_name + '[/b]%s in [b]%d[/b] seconds please!' % [in_asteroid, travel_distance]
