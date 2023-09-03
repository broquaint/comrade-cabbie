class_name DestPoint, "res://assets/dest point icon.png"

extends Area2D

signal pickup_entered(point)
signal dropoff_entered(point)
signal passenger_pickup_ready(point)
signal passenger_dropoff_ready(point)
signal passenger_pickup_interrupted(point)
signal passenger_dropoff_interrupted(point)

export var point_type : String
export var point_name : String
# There's got to be a better way …
var real_pos : Vector2

func _ready():
	$Label.text = point_name

	connect('body_entered', self, 'point_entered')
	connect('body_exited', self, 'point_exited')
	$Timer.connect('timeout', self, 'passenger_done')

func get_asteroid():
	return get_node('../..')

func base_point_exited():
	if not $Timer.is_stopped():
		$Timer.stop()
		emit_signal(('passenger_%s_interrupted' % point_type), self)
	$ProgressMeter.hide()

func passenger_done():
	$ProgressMeter.hide()
	emit_signal(('passenger_%s_ready' % point_type), self)
