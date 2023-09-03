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
const UNLOCK_THRESHOLD = 5

var current_state = States.TITLE
var current_asteroid : Node2D
var asteroid_satisfaction = {}
var settings = {}

var journeys : Array
var unlocks : Dictionary
var unlock_order : Array
var asteroids_done : Array

const SAVE_GAME_PATH = 'user://savegame.json'
func save_game_state():
	var save = {
		# Don't store the actual node
		current_asteroid_name = current_asteroid.name,
		asteroid_satisfaction = asteroid_satisfaction,

		journeys = journeys,
		unlocks = unlocks,
		unlock_order = unlock_order,
		asteroids_done = asteroids_done,

		play_time = root().play_time()
	}
	var save_game = File.new()
	save_game.open(SAVE_GAME_PATH, File.WRITE)
	save_game.store_string(to_json(save))
	save_game.close()

func load_game_state():
	var save_game = File.new()
	save_game.open(SAVE_GAME_PATH, File.READ)
	var state = parse_json(save_game.get_as_text())
	save_game.close()

	# Don't store the actual node
	self.current_asteroid = asteroid_node(state['current_asteroid_name'])
	self.asteroid_satisfaction = state['asteroid_satisfaction']

	self.journeys = state['journeys']
	self.unlocks = state['unlocks']
	self.unlock_order = state['unlock_order']
	self.asteroids_done = state['asteroids_done']

	for asteroid in asteroids_done:
		asteroid_node(asteroid + 'Asteroid').lift_barrier()

	return state

func has_game_save():
	return File.new().file_exists(SAVE_GAME_PATH)

func initialize():
	self.current_asteroid = asteroid_node('HomeAsteroid')
	if not asteroid_satisfaction.empty():
		for k in asteroid_satisfaction.keys():
			self.asteroid_satisfaction[k] = DEFAULT_SATISFACTION
	else:
		self.asteroid_satisfaction = {}
	self.current_state = States.PLAYING
	self.journeys = []
	self.unlocks = {
		Services = false,
		Goods = false,
		Study = false,
		Home = false,
	}
	self.unlock_order = ['Home', 'Services', 'Study', 'Goods']
	self.asteroids_done = []

const CONFIG_PATH = 'user://gamestate.cfg'
func load_settings():
	var config = ConfigFile.new()
	var res = config.load(CONFIG_PATH)
	if res != OK:
		# Shouldn't happen. Could happen. Meh.
		settings = {
			seen_intro = false,
			music = true,
			sfx = true,
			fastest_time = 31449601
		}
	else:
		settings['seen_intro']   = config.get_value('settings', 'seen_intro', false)
		settings['music']        = config.get_value('settings', 'music', true)
		settings['sfx']          = config.get_value('settings', 'sfx', true)
		settings['fastest_time'] = config.get_value('settings', 'fastest_time', 31449601)

func save_setting_value(k, v):
	var config = ConfigFile.new()
	for sk in settings.keys():
		config.set_value('settings', sk, settings[sk])
	config.set_value('settings', k, v)
	settings[k] = v
	config.save(CONFIG_PATH)

func set_seen_intro(seen_state):
	save_setting_value('seen_intro', seen_state)

func set_music(mute_state):
	save_setting_value('music', mute_state)

func set_sfx(mute_state):
	save_setting_value('sfx', mute_state)

func save_completion_time(new_time):
	if new_time < settings['fastest_time']:
		save_setting_value('fastest_time', new_time)

func intro_acknowledged():
	set_seen_intro(true)

func set_current_asteroid(new_asteroid):
	current_asteroid = asteroid_node("%sAsteroid" % new_asteroid)

func root():
	return get_node('/root/Root')

func asteroid_node(name):
	return root().get_node(name)

func on_new_dropoff(dropoff: DropoffPoint, _travel_time: float, journey_score: int):
	var asteroid = dropoff.get_asteroid()
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
	# Don't emit any signals when satisfaction is full.
	if prev_satisfaction != 100 and local_satisfaction != 100:
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

	save_game_state()

func on_asteroid_change(_from, _to):
	call_deferred('save_game_state')

func good_journey_count():
	if unlock_order.empty():
		return 0
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
			asteroids_done.append('Home')
			emit_signal('asteroid_unlock', 'Services')
			journeys = []
		elif not unlocks['Study']:
			unlocks['Study'] = true
			asteroids_done.append('Services')
			emit_signal('asteroid_unlock', 'Study')
			journeys = []
		elif not unlocks['Goods']:
			unlocks['Goods'] = true
			asteroids_done.append('Study')
			emit_signal('asteroid_unlock', 'Goods')
			journeys = []
		elif not unlocks['Home']:
			unlocks['Home'] = true
			asteroids_done.append('Goods')
			emit_signal('asteroid_unlock', 'Home')
			journeys = []

func unlocked_asteroids():
	return asteroids_done
