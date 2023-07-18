extends Control

func on_new_pickup(dropoff: Node):
	$Container/Destination.text = dropoff.name

func on_new_dropoff():
	$Container/Destination.text = '...'
