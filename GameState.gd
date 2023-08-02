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

const DEFAULT_SATISFACTION = 60.0

var current_state = States.PLAYING
var current_asteroid : Node2D
var journeys = []
var overall_satisfaction  = DEFAULT_SATISFACTION
var asteroid_satisfaction = {}

func on_picking_up(pickup: PickupPoint):
	pass
func on_new_pickup(dropoff: DropoffPoint, calc_travel_distance: int):
	pass

func on_asteroid_change(_node, tunnel: Tunnel):
	var asteroid_name = current_asteroid.name.replace('Asteroid', '')
	var new_asteroid = tunnel.AsteroidTwo if asteroid_name == tunnel.AsteroidOne else tunnel.AsteroidOne
	current_asteroid = get_node("/root/Root/%sAsteroid" % new_asteroid)

func on_new_dropoff(_dropoff: DropoffPoint, asteroid: Node2D, travel_time: float, journey_score: int):
	var satisfaction = asteroid_satisfaction[asteroid.name]
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

	asteroid_satisfaction[asteroid.name] = clamp(satisfaction * ratio, 0, 100)

	var total_satisfaction = 0
	for s in asteroid_satisfaction.values():
		total_satisfaction += s
	overall_satisfaction = total_satisfaction / asteroid_satisfaction.size()

	journeys.append(journey_score)
