extends Node

enum States {
	MAIN_MENU,
	TRANSITIONING,
	PAUSED,
	PLAYING
}

enum JourneyScore {
	SPEEDY,
	FAST,
	TIMELY,
	TARDY,
	SLUGGISH
}

var current_state = States.PLAYING
var journeys = []
var satisfaction = 50.0

func on_picking_up(pickup: Area2D):
	pass
func on_new_pickup(dropoff: Area2D, calc_travel_distance: int):
	pass
func on_new_dropoff(_dropoff: Area2D, travel_time: float, travel_estimate: float):
	pass
