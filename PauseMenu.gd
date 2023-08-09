extends VBoxContainer

func _ready():
	$Resume.connect('pressed', self, 'resume_game')
	$Restart.connect('pressed', self, 'restart_game')
	$Leave.connect('pressed', self, 'leave_game')

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

func restart_game():
	GameState.initialize()
	get_node('/root/Root').setup()
	resume_game()

func leave_game():
	GameState.initialize()
	get_node('/root/Root').setup()
	hide()
	get_node('%PauseOverlay').hide()
	$"../TitleMenu".show_title()
