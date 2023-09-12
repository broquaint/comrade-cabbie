extends Node2D

func _ready():
	# Setup general game state.
	GameState.initialize('TestAsteroid')
	# Get the player ready.
	$Player.initialize()

	$Player.connect("movement_update", self, "on_player_move")

# {velocity=velocity, net_angular_acceleration=net_angular_acceleration, angular_velocity=angular_velocity}
func on_player_move(status):
	get_node('%SpeedValue').text = "%.2f (%.2f)" % [status['velocity'].length(), status['max_speed']]
