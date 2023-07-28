class_name DropoffPoint

extends Area2D

export var point_name : String
# There's got to be a better way …
var real_pos : Vector2

func _ready():
	$Label.text = point_name
	# Cribbed from: https://ask.godotengine.org/149058/changing-the-background-color-of-a-label
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#c8595652")
	$Label.add_stylebox_override("normal", sb)
