extends AudioStreamPlayer


# export(Texture) var north_pickup_tex
export(AudioStreamSample) var no_boost        = preload("res://assets/ship1.wav")
export(AudioStreamSample) var boost_some      = preload("res://assets/ship2.wav")
export(AudioStreamSample) var boost_speedy    = preload("res://assets/ship3.wav")
export(AudioStreamSample) var boost_ludicrous = preload("res://assets/ship4.wav")

func _ready():
	self.stream = no_boost

func vroom(boost_type):
#	stop()
	match boost_type:
		0:
			self.stream = no_boost
		1:
			self.stream = boost_some
		2:
			self.stream = boost_speedy
		3:
			self.stream = boost_ludicrous
	play()
