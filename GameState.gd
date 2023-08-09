extends Node

signal satisfaction_update(text)

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
var overall_satisfaction  = DEFAULT_SATISFACTION
var asteroid_satisfaction = {}

func initialize():
	current_asteroid = get_node('/root/Root/HomeAsteroid')
	overall_satisfaction  = DEFAULT_SATISFACTION
	if not asteroid_satisfaction.empty():
		for k in asteroid_satisfaction.keys():
			asteroid_satisfaction[k] = DEFAULT_SATISFACTION
	else:
		asteroid_satisfaction = {}
	current_state = States.PLAYING

func on_picking_up(pickup: PickupPoint):
	pass
func on_new_pickup(dropoff: DropoffPoint, calc_travel_distance: int):
	pass

func on_asteroid_change(_node, tunnel: Tunnel):
	var asteroid_name = current_asteroid.name.replace('Asteroid', '')
	var new_asteroid = tunnel.AsteroidTwo if asteroid_name == tunnel.AsteroidOne else tunnel.AsteroidOne
	current_asteroid = get_node("/root/Root/%sAsteroid" % new_asteroid)

func on_new_dropoff(_dropoff: DropoffPoint, asteroid: Node2D, travel_time: float, journey_score: int):
	var prev_satisfaction = asteroid_satisfaction[asteroid.name]
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

	asteroid_satisfaction[asteroid.name] = clamp(prev_satisfaction * ratio, 0, 100)

	var prev_whole_satisfaction = overall_satisfaction
	var total_satisfaction = 0
	for s in asteroid_satisfaction.values():
		total_satisfaction += s
	overall_satisfaction = total_satisfaction / asteroid_satisfaction.size()

	var local_satisfaction = asteroid_satisfaction[asteroid.name]
	if prev_satisfaction == local_satisfaction:
		emit_signal('satisfaction_update', 'No change to satisfaction levels ._.')
	else:
		var aname = asteroid.name.replace('Asteroid', '')
		var direction = 'increased' if prev_satisfaction < local_satisfaction else 'decreased'
		var local_delta = local_satisfaction - prev_satisfaction
		var whole_delta = overall_satisfaction - prev_whole_satisfaction
		emit_signal(
			'satisfaction_update',
			'%s Satisfaction [i]%s[/i] by [b]%.2f[/b] to [b]%.2f[/b]%% and overall satisaction by [b]%.2f[/b] to [b]%.2f[/b]%%' % [aname, direction, local_delta, local_satisfaction, whole_delta, overall_satisfaction]
		)
