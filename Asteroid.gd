class_name Asteroid, "res://assets/asteroid class icon.png"

extends TileMap

export var start_position : Vector2
export var map_name : String

# Used in subclasses!
# warning-ignore:unused_signal
signal announce_unlock(msg)

func on_asteroid_unlocked(_asteroid):
	pass

func lift_barrier():
	pass
