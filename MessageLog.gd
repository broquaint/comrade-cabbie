extends Node2D

var msg_id = 0

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
