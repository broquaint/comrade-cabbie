extends Control

func on_picking_up(pickup: Node):
	#$Container/Destination.text = 'Picking up from [b]' + pickup.point_name + '[/b]'
	$Container/Destination.bbcode_text = 'Picking up from [b]' + pickup.point_name + '[/b]'

func on_new_pickup(dropoff: Node):
	$Container/Destination.bbcode_text = 'Dropping off at [b]' + dropoff.point_name + '[/b]'

func on_distance_update(distance: float):
	$Container/Distance.bbcode_text = '[b]%s[/b]m' % distance

func on_new_dropoff():
	pass
	# $Container/Destination.text = '...'
