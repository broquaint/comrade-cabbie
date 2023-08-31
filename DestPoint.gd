class_name DestPoint, "res://assets/dest point icon.png"

extends Area2D

export var point_name : String
# There's got to be a better way …
var real_pos : Vector2

func _ready():
	$Label.text = point_name

func get_asteroid():
	return get_node('../..')
