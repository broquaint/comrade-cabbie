extends VBoxContainer

func _ready():
	$Start.connect('pressed', self, 'start_game')
	$Settings.connect('pressed', self, 'show_settings')
	$Credits.connect('pressed', self, 'show_credits')
	$'../SettingsMenu'.connect('left_title_settings', self, 'leave_settings')
	
	show_title()

func show_title():
	get_tree().paused = true
	$'../Title'.show()
	show()
	$Start.grab_focus()

func start_game():
	GameState.current_state = GameState.States.PLAYING
	get_tree().paused = false
	root().play_music()
	$'../Title'.hide()
	hide()

func show_settings():
	hide()
	$'../SettingsMenu'.show()
	$'../SettingsMenu/Music'.grab_focus()

func show_credits():
	pass

func root():
	return get_node('/root/Root')

func toggle_music():
	root().toggle_music()

func toggle_sfx():
	root().toggle_sfx()

func leave_settings():
	show()
	$Settings.grab_focus()

