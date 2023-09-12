extends Control

func on_picking_up(pickup: Node):
	#$Container/Destination.text = 'Picking up from [b]' + pickup.point_name + '[/b]'
	$Container/Destination.bbcode_text = 'Picking up from [b]' + pickup.point_name + '[/b]'

func on_new_pickup(dropoff: Node, travel_distance: int):
	var msg = dropoff.announce_msg(travel_distance).replace('Drop me off at ', '').replace(' please!', '')
	$Container/Destination.bbcode_text = msg

func on_travel_time_update(travel_time: float):
	$Container/TravelTime.bbcode_text = '[b]%.1f[/b]secs' % travel_time

func on_movement_update(status: Dictionary):
	var velocity = status.velocity
	var net_angular_acceleration = status.net_angular_acceleration
	var angular_velocity = status.angular_velocity
	$Container/Speed.bbcode_text = "[b]%d[/b]m/s (%.2f - %.2f)" % [int(velocity.length() / 8), net_angular_acceleration, angular_velocity]
