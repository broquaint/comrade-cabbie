extends Node2D

var asteroids = {}
var pickups   = {}
var dropoffs  = {}

var community_satisfaction = 75

func _ready():
	randomize()

	# Setup pickup/dropoff points
	_build_points()
	# Connect boosts on major paths
	_connect_boosts()
	# Connect asteroids with "tunnels"
	_connect_tunnels()

	# Connect up all the signals
	$Player.connect('new_dropoff', GameState, 'on_new_dropoff')
	
	$Player.connect('picking_up', $HUD/Control, 'on_picking_up')
	$Player.connect('new_pickup', $HUD/Control, 'on_new_pickup')
	$Player.connect('new_pickup', $HUD/DestFlashControl, 'on_new_pickup')
	$Player.connect('new_dropoff', $HUD/DestFlashControl, 'on_new_dropoff')
	$Player.connect('new_dropoff', $HUD/SatisfactionMeter, 'on_new_dropoff')
	$Player.connect('distance_update', $HUD/Compass, 'on_distance_update')
	$Player.connect('travel_time_update', $HUD/Control, 'on_travel_time_update')
	$Player.connect('compass_update', $HUD/Compass, 'on_compass_update')
	$Player.connect('compass_update', $HUD/Compass/Needle, 'on_compass_update')

	$HUD/IntroPopup.connect('confirmed', GameState, 'intro_acknowledged')
	GameState.connect('satisfaction_update', $HUD/MessageLog, 'on_message')
	for a in asteroids.values():
		GameState.connect('asteroid_unlock', a, 'on_asteroid_unlocked')
		a.connect('announce_unlock', $HUD/BannerPanel, 'on_announce')
		a.connect('announce_unlock', $HUD/MessageLog, 'on_message')
	GameState.connect('asteroid_unlock', self, 'on_asteroid_unlocked')

	GameState.load_data()

	if not GameState.settings['music']:
		AudioServer.set_bus_mute(1, true)
	if not GameState.settings['sfx']:
		AudioServer.set_bus_mute(2, true)

	# No idea why all these streams are looping.
	$UnlockSound.stream.loop = false
	$SoundTrack.stream.loop = true
	setup()

# Used during start+restart
func setup():
	GameState.initialize()
	$HUD/DestFlashControl.reset()
	$HUD/MessageLog.clear_log()
	# Setup general game state.
	$Player.initialize()
	$Player.position = Vector2(2000, 1000) # Home
#	$Player.position = Vector2(10065, 3250) # Services
#	$Player.position = Vector2(9428, 12950) # Study
#	$Player.position = Vector2(200, 4000) # Goods
	$Player.set_next_pickup($HomeAsteroid)
	$HUD/SatisfactionMeter.set_progress_meter()
	$HUD/SatisfactionMeter.set_asteroid_meter($HomeAsteroid)

# Used coming from Title screen
func start_game():
	GameState.current_state = GameState.States.PLAYING
	get_tree().paused = false
	play_music()
	if not GameState.settings['seen_intro']:
		$HUD/IntroPopup.popup()

func play_music():
	if $SoundTrack.playing:
		$SoundTrack.stop()
	$SoundTrack.stream.loop = true
	# Don't adjust volume if music is muted.
	if GameState.settings['music']:
		var fade_in = $SoundTrack/FadeIn
		fade_in.interpolate_property(
			$SoundTrack, 'volume_db', -60.0, -25.0, 4,
			Tween.TRANS_LINEAR, Tween.EASE_IN
		)
		fade_in.start()
	$SoundTrack.play()

func toggle_music():
	var music_bus = AudioServer.get_bus_index("Music")
	var mute_state = not AudioServer.is_bus_mute(music_bus)
	AudioServer.set_bus_mute(music_bus, mute_state)
	GameState.set_music(not mute_state)

func toggle_sfx():
	var sfx_bus = AudioServer.get_bus_index("SFX")
	var mute_state = not AudioServer.is_bus_mute(sfx_bus)
	AudioServer.set_bus_mute(sfx_bus, mute_state)
	GameState.set_sfx(not mute_state)

func on_asteroid_unlocked(_asteroid):
	yield(get_tree().create_timer(2), "timeout")
	$UnlockSound.play()

func _build_points():
	for kid in get_children():
		if "Asteroid" in kid.name:
			pickups[kid.name] = []
			dropoffs[kid.name] = []
			asteroids[kid.name] = kid
			GameState.asteroid_satisfaction[kid.name] = GameState.DEFAULT_SATISFACTION
	for k in asteroids.keys():
		var v = asteroids[k]
		for point in v.get_node('Pickups').get_children():
			pickups[k].append(point)
			point.real_pos = point.position + v.position
			point.connect('body_entered', $Player, 'pickup_point_entered', [point, v])
		for point in v.get_node('Dropoffs').get_children():
			dropoffs[k].append(point)
			point.real_pos = point.position + v.position
			point.connect('body_entered', $Player, 'dropoff_point_entered', [point, v])

func _connect_boosts():
	for a in asteroids.values():
		# Not all asteroids have paths yet.
		if not a.has_node('MajorPaths'):
			continue
		for p in a.get_node('MajorPaths').get_children():
			for b in p.get_children():
				if b is Area2D:
					b.connect('body_entered', $Player, 'boost_entered')

func _connect_tunnels():
	for tunnel in [$HomeGoodsTunnel, $HomeServicesTunnel, $ServicesStudyTunnel, $GoodsStudyTunnel]:
		tunnel.connect('tunnel_entered', $Player, 'on_asteroid_change')
		tunnel.connect('tunnel_entered', $HUD/DestFlashControl, 'on_asteroid_change')
		tunnel.connect('tunnel_entered', $HUD/SatisfactionMeter, 'on_asteroid_change')
