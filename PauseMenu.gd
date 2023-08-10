extends VBoxContainer

func _ready():
	$Resume.connect('pressed', self, 'resume_game')
	$Settings.connect('pressed', self, 'show_settings')
	$Restart.connect('pressed', self, 'restart_game')
	$Leave.connect('pressed', self, 'leave_game')
	$'../SettingsMenu/Music'.connect('pressed', self, 'toggle_music')
	$'../SettingsMenu/SFX'.connect('pressed', self, 'toggle_sfx')
	$'../SettingsMenu/Back'.connect('pressed', self, 'leave_settings')

func root():
	return get_node('/root/Root')

func _process(_delta):
	if Input.is_action_just_pressed('pause'):
		match GameState.current_state:
			GameState.States.PLAYING:
				pause_game()
			GameState.States.PAUSED:
				resume_game()

func pause_game():
	get_tree().paused = true
	show()
	get_node('%PauseOverlay').show()
	$Resume.grab_focus()
	GameState.current_state = GameState.States.PAUSED

func resume_game():
	get_tree().paused = false
	hide()
	get_node('%PauseOverlay').hide()
	GameState.current_state = GameState.States.PLAYING

func show_settings():
	hide()
	$'../SettingsMenu'.show()
	$'../SettingsMenu/Music'.grab_focus()

func restart_game():
	GameState.initialize()
	root().setup()
	resume_game()

func leave_game():
	GameState.initialize()
	root().setup()
	hide()
	get_node('%PauseOverlay').hide()
	$"../TitleMenu".show_title()

func toggle_music():
	root().toggle_music()

func toggle_sfx():
	root().toggle_sfx()

func leave_settings():
	$'../SettingsMenu'.hide()
	show()
	$Settings.grab_focus()
