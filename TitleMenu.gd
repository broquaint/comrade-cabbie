extends VBoxContainer

func _ready():
	$Start.connect('pressed', self, 'start_game')
	$Settings.connect('pressed', self, 'show_settings')
	$Credits.connect('pressed', self, 'show_credits')
	
	show_title()

func show_title():
	get_tree().paused = true
	$'../Title'.show()
	show()
	$Start.grab_focus()

func start_game():
	get_tree().paused = false
	$'../Title'.hide()
	hide()

func show_settings():
	pass

func show_credits():
	pass
