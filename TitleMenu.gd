extends VBoxContainer

func _ready():
	$NewGame.connect('pressed', self, 'start_game')
	$ContinueGame.connect('pressed', self, 'continue_game')
	$Settings.connect('pressed', self, 'show_settings')
	$Credits.connect('pressed', self, 'show_credits')
	$'../SettingsMenu'.connect('left_title_settings', self, 'leave_settings')

	show_title()

func show_title():
	get_tree().paused = true
	$'../Title'.show()
	show()
	if not GameState.has_game_save():
		$ContinueGame.hide()
		$NewGame.grab_focus()
	else:
		$ContinueGame.show()
		$ContinueGame.grab_focus()

func start_game():
	root().start_new_game()
	$'../Title'.hide()
	hide()

func continue_game():
	root().load_previous_game()
	$'../Title'.hide()
	hide()

func show_settings():
	hide()
	$'../SettingsMenu'.enable()

func show_credits():
	$'../CreditsPopup'.popup()

func root():
	return get_node('/root/Root')

func toggle_music():
	root().toggle_music()

func toggle_sfx():
	root().toggle_sfx()

func leave_settings():
	show()
	$Settings.grab_focus()

