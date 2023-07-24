class_name DropoffPoint

extends Area2D

export var point_name : String

func _ready():
	$Label.text = point_name
