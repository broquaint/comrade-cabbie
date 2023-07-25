extends Control

func on_new_pickup(point: DropoffPoint):
	get_parent().get_node('AnimationPlayer').play("DestFlash")
	$DestFlashText.bbcode_text = 'Drop me off at [b]' + point.point_name + '[/b]'
