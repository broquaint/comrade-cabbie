extends Control

var orig_rect_size : int
var orig_rec2_size : int
var orig_text_size : int

func _ready():
	# Awful lazy way of handling different sizes of flashes >_<
	orig_rect_size = $ColorRect.rect_size.x
	orig_rec2_size = $ColorRect2.rect_size.x
	orig_text_size = $DestFlashText.rect_size.x

func flash():
	get_parent().get_node('AnimationPlayer').play("DestFlash")

func set_text(text):
	$DestFlashText.bbcode_text = text

func on_new_pickup(point: DropoffPoint, travel_distance: int):
	flash()
	$ColorRect.rect_size.x = orig_rect_size
	$ColorRect2.rect_size.x = orig_rec2_size
	$DestFlashText.rect_size.x = orig_text_size
	set_text('Drop me off at [b]' + point.point_name + '[/b] in [b]%d[/b] seconds please!' % travel_distance)

const good_time_text = [
	'that was fast!',
	'thank you so much!',
	'quick as you like!'
]
const exact_time_text = [
	'right on time!',
	'perfect timing!'
]
const sub_time_text = [
	'got there in the end',
	'better late than never',
]
func on_new_dropoff(dropoff, travel_time, travel_estimate):
	flash()
	var text_choice : Array
	if travel_time < travel_estimate:
		text_choice = good_time_text
	elif int(travel_time) == int(travel_estimate):
		text_choice = exact_time_text
	else:
		text_choice = sub_time_text
	var timeliness = text_choice[randi() % text_choice.size()]
	$ColorRect.rect_size.x += 150
	$ColorRect2.rect_size.x += 150
	$DestFlashText.rect_size.x += 150
	set_text('Reached [b]%s[/b] in [b]%d[/b] seconds, %s' % [dropoff.point_name, travel_time, timeliness])
