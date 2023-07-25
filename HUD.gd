extends Control

func on_picking_up(pickup: Node):
	#$Container/Destination.text = 'Picking up from [b]' + pickup.point_name + '[/b]'
	$Container/Destination.bbcode_text = 'Picking up from [b]' + pickup.point_name + '[/b]'

func on_new_pickup(dropoff: Node, calc_travel_distance: int):
	$Container/Destination.bbcode_text = 'Dropping off at [b]' + dropoff.point_name + '[/b] in [b]%d[/b] secs' % calc_travel_distance

func on_travel_time_update(travel_time: float):
	$Container/TravelTime.bbcode_text = '[b]%.1f[/b]secs' % travel_time
