extends Node2D

const TRANSPARENT = Color('#00ffffff')
const APPARENT    = Color('#ffffffff')

var msg_id : int

func _ready():
	$FadeTimer.connect('timeout', self, 'disappear')
	setup()

func setup():
	msg_id = 0
	clear_log()

func clear_log():
	for kid in get_children():
		if kid is RichTextLabel and kid != $Message:
			remove_child(kid)

func on_message(msg):
	msg_id += 1
	var mn = $Message.duplicate()
	mn.bbcode_text = ('%d: ' % msg_id) + msg
	for kid in get_children():
		if kid is RichTextLabel and kid != $Message:
			kid.rect_position += Vector2(0, 28)
			if kid.rect_position.y > 100:
				remove_child(kid)
	add_child(mn)
	mn.show()

	if modulate != APPARENT:
		appear()

	$FadeTimer.start(10.0)

func appear():
	# It's possible we're fading out, so stop that to fade in again.
	$FadeOutTween.stop_all()
	var ft = $FadeInTween
	ft.interpolate_property(
		self, 'modulate',
		self.modulate, APPARENT, 0.5,
		Tween.TRANS_QUAD, Tween.EASE_IN
	)
	ft.start()

func disappear():
	var ft = $FadeOutTween
	ft.interpolate_property(
		self, 'modulate',
		self.modulate, TRANSPARENT, 2,
		Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	ft.start()
