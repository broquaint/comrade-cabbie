extends Node

signal satisfaction_update(text)
signal asteroid_unlock(asteroid)

enum States {
	TITLE,
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

var current_state = States.TITLE
var current_asteroid : Node2D
var asteroid_satisfaction = {}
var settings = {}

var journeys = []
var unlocks = {
	Services = false,
	Goods = false,
	Study = false,
	Home = false,
}
var unlock_order = ['Home', 'Services', 'Study', 'Goods']

func initialize():
	current_asteroid = get_node('/root/Root/HomeAsteroid')
	if not asteroid_satisfaction.empty():
		for k in asteroid_satisfaction.keys():
			asteroid_satisfaction[k] = DEFAULT_SATISFACTION
	else:
		asteroid_satisfaction = {}
	current_state = States.PLAYING

const CONFIG_PATH = 'user://gamestate.cfg'
func load_data():
	var config = ConfigFile.new()
	var res = config.load(CONFIG_PATH)
	if res != OK:
		# Shouldn't happen. Could happen. Meh.
		settings = {
			seen_intro = false,
			music = true,
			sfx = true,
		}
	else:
		settings['seen_intro'] = config.get_value('settings', 'seen_intro', false)
		settings['music']      = config.get_value('settings', 'music', true)
		settings['sfx']        = config.get_value('settings', 'sfx', true)

func save_setting_value(k, v):
	var config = ConfigFile.new()
	for sk in settings.keys():
		config.set_value('settings', sk, settings[sk])
	config.set_value('settings', k, v)
	config.save(CONFIG_PATH)

func set_seen_intro(seen_state):
	save_setting_value('seen_intro', seen_state)

func set_music(mute_state):
	save_setting_value('music', mute_state)

func set_sfx(mute_state):
	save_setting_value('sfx', mute_state)

func intro_acknowledged():
	set_seen_intro(true)

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

	var local_satisfaction = asteroid_satisfaction[asteroid.name]
	if prev_satisfaction == local_satisfaction:
		emit_signal('satisfaction_update', 'No change to satisfaction levels ._.')
	else:
		var aname = asteroid.name.replace('Asteroid', '')
		var direction = 'increased' if prev_satisfaction < local_satisfaction else 'decreased'
		var local_delta = local_satisfaction - prev_satisfaction
		emit_signal(
			'satisfaction_update',
			'%s Satisfaction [i]%s[/i] by [b]%.2f[/b] to [b]%.2f[/b]%%' % [aname, direction, local_delta, local_satisfaction]
		)

	journeys.push_front({score = journey_score, asteroid = asteroid.name.replace('Asteroid', '')})
	handle_unlocks()

const UNLOCK_THRESHOLD = 5
func good_journey_count():
	var unlock_target = unlock_order[0]
	var good_journeys = 0
	for js in journeys:
		if js['score'] <= JourneyScore.TIMELY and js['asteroid'] == unlock_target:
			good_journeys += 1
	return clamp(good_journeys, 0, UNLOCK_THRESHOLD)

func unlocking_now():
	if unlock_order.empty():
		return false
	return good_journey_count() >= UNLOCK_THRESHOLD

func handle_unlocks():
	if unlocking_now():
		unlock_order.pop_front()
		if not unlocks['Services']:
			unlocks['Services'] = true
			emit_signal('asteroid_unlock', 'Services')
			journeys = []
		elif not unlocks['Study']:
			unlocks['Study'] = true
			emit_signal('asteroid_unlock', 'Study')
			journeys = []
		elif not unlocks['Goods']:
			unlocks['Goods'] = true
			emit_signal('asteroid_unlock', 'Goods')
			journeys = []
		elif not unlocks['Home']:
			unlocks['Home'] = true
			emit_signal('asteroid_unlock', 'Home')
			journeys = []
