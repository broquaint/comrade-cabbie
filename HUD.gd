extends Control

func on_picking_up(pickup: Node):
	$Container/Destination.text = 'Picking up from - ' + pickup.point_name

func on_new_pickup(dropoff: Node):
	$Container/Destination.text = 'Dropping off at - ' + dropoff.point_name

func on_new_dropoff():
	pass
	# $Container/Destination.text = '...'
