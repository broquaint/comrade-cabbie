class_name PickupPoint

extends Area2D

export var point_name : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = point_name
