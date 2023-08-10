extends VBoxContainer

signal left_title_settings()
signal left_pause_settings()

func _ready():
	$Music.connect('pressed', self, 'toggle_music')
	$SFX.connect('pressed', self, 'toggle_sfx')
	$Back.connect('pressed', self, 'leave_settings')

func enable():
	show()
	$Music.grab_focus()
	if not GameState.settings['music']:
		$Music.pressed = false
	if not GameState.settings['sfx']:
		$SFX.pressed = false

func root():
	return get_node('/root/Root')

func toggle_music():
	root().toggle_music()

func toggle_sfx():
	root().toggle_sfx()

func leave_settings():
	hide()
	# Not elegant, but it will do ...
	if $'../Title'.visible:
		emit_signal('left_title_settings')
	else:
		emit_signal('left_pause_settings')
