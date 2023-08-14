class_name Tunnel

extends Area2D

export var AsteroidOne : String
export var AsteroidTwo : String

signal tunnel_entered(from, to)

func _ready():
	connect('body_entered', self, 'on_tunnel_entered')

func on_tunnel_entered(_body):
	var from = GameState.current_asteroid.name.replace('Asteroid', '')
	var to   = AsteroidTwo if from == AsteroidOne else AsteroidTwo
	# Do this here so subsequent signal handlers have a current view.
	GameState.set_current_asteroid(to)
	emit_signal('tunnel_entered', from, to)
