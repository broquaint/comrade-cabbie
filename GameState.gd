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
var satisfaction : float = 60.0

func on_picking_up(pickup: PickupPoint):
	pass
func on_new_pickup(dropoff: DropoffPoint, calc_travel_distance: int):
	pass

func on_new_dropoff(_dropoff: DropoffPoint, travel_time: float, journey_score: int):
	var satisfaction_before : float = satisfaction
	var ratio : float
	match journey_score:
		JourneyScore.SPEEDY:
			ratio = 1.075
		JourneyScore.FAST:
			ratio = 1.05
		JourneyScore.TIMELY:
			ratio = 1.025
		JourneyScore.TARDY:
			ratio = 1.0
		JourneyScore.SLUGGISH:
			ratio = 0.95
	satisfaction = clamp(satisfaction * ratio, 0, 100)
