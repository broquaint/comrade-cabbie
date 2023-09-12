extends Node2D

func _ready():
	randomize()

	# Now everything is ready build up a view of the asteroids + points.
	GameState.build_system_data()

	# Setup pickup/dropoff points
	_connect_points()
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
	$Player.connect('movement_update', $HUD/Control, 'on_movement_update')
	$Player.connect('compass_update', $HUD/Compass, 'on_compass_update')
	$Player.connect('compass_update', $HUD/Compass/Needle, 'on_compass_update')

	$HUD/IntroPopup.connect('confirmed', GameState, 'intro_acknowledged')
	GameState.connect('satisfaction_update', $HUD/MessageLog, 'on_message')
	for a in GameState.asteroids.values():
		GameState.connect('asteroid_unlock', a, 'on_asteroid_unlocked')
		a.connect('announce_unlock', $HUD/BannerPanel, 'on_announce')
		a.connect('announce_unlock', $HUD/MessageLog, 'on_message')
	GameState.connect('asteroid_unlock', self, 'on_asteroid_unlocked')
	$GoodsAsteroid.connect('announce_unlock', self, 'unlocks_complete')

	GameState.load_settings()

	if not GameState.settings.music:
		AudioServer.set_bus_mute(1, true)
	if not GameState.settings.sfx:
		AudioServer.set_bus_mute(2, true)

	# No idea why all these streams are looping.
	$UnlockSound.stream.loop = false
	$SoundTrack.stream.loop = true
	setup()

# Used during start+restart
func setup():
	# Setup general game state.
	GameState.initialize()
	# Get the player ready.
	$Player.initialize()
	# Set all HUD elements to default.
	$HUD.initialize()

const TIMER_LIMIT = 86400*7*52
# Used coming from Title screen
func start_new_game():
	GameState.current_state = GameState.States.PLAYING
	get_tree().paused = false
	play_music()
	# Haven't tested the edge case of the game running for 1 year.
	$PlayTime.start(TIMER_LIMIT)
	if not GameState.settings.seen_intro:
		$HUD/IntroPopup.popup()

func load_previous_game():
	# XXX Not using current_state ATM
	GameState.current_state = GameState.States.PLAYING
	get_tree().paused = false
	play_music()

	var state = GameState.load_game_state()
	$PlayTime.start(state.play_time)

	$Player.initialize()

	$HUD/SatisfactionMeter.set_progress_meter()
	$HUD/SatisfactionMeter.set_asteroid_meter(GameState.current_asteroid)

func play_time():
	return TIMER_LIMIT - $PlayTime.time_left

func unlocks_complete(_asteroid):
	# Using a Timer as that handles games pauses seamlessly.
	var completion_time = TIMER_LIMIT - $PlayTime.time_left
	$PlayTime.stop()
	GameState.save_completion_time(completion_time)
	$HUD/CompletionPopup.journeys_end(completion_time, GameState.settings.fastest_time)

func play_music():
	$SoundTrack.stream.loop = true
	# Don't adjust volume if music is muted.
	if GameState.settings.music:
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

func _connect_points():
	for asteroid_points in GameState.pickups.values():
		for point in asteroid_points:
			point.connect('passenger_pickup_ready', $Player, 'passenger_collected')
			point.connect('passenger_pickup_interrupted', $Player, 'passenger_pickup_missed')
	for asteroid_points in GameState.dropoffs.values():
		for point in asteroid_points:
			point.connect('passenger_dropoff_ready', $Player, 'passenger_deposited')
			point.connect('passenger_dropoff_interrupted', $Player, 'passenger_dropoff_missed')

func _connect_boosts():
	for a in GameState.asteroids.values():
		# Not all asteroids have paths yet.
		if not a.has_node('MajorPaths'):
			continue
		for p in a.get_node('MajorPaths').get_children():
			for b in p.get_children():
				if b is Area2D:
					b.connect('body_entered', $Player, 'boost_entered')

func _connect_tunnels():
	for tunnel in [$HomeGoodsTunnel, $HomeServicesTunnel, $ServicesStudyTunnel, $GoodsStudyTunnel]:
		tunnel.connect('tunnel_entered', GameState, 'on_asteroid_change')
		tunnel.connect('tunnel_entered', $Player, 'on_asteroid_change')
		tunnel.connect('tunnel_entered', $HUD/DestFlashControl, 'on_asteroid_change')
		tunnel.connect('tunnel_entered', $HUD/SatisfactionMeter, 'on_asteroid_change')
