extends VBoxContainer	

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		match GameState.current_state:
			GameState.States.PLAYING:
				get_tree().paused = true
				show()
				get_node('%PauseOverlay').show()
				GameState.current_state = GameState.States.PAUSED
			GameState.States.PAUSED:
				get_tree().paused = false
				hide()
				get_node('%PauseOverlay').hide()
				GameState.current_state = GameState.States.PLAYING
