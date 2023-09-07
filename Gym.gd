extends Node2D

func _ready():
	# Setup general game state.
	GameState.initialize('TestAsteroid')
	# Get the player ready.
	$Player.initialize()
