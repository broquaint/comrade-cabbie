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
	$'../FlashAnimationPlayer'.play("DestFlash")

func set_text(text):
	$DestFlashText.bbcode_text = text

func on_new_pickup(point: DropoffPoint, travel_distance: int):
	flash()
	$ColorRect.rect_size.x = orig_rect_size
	$ColorRect2.rect_size.x = orig_rec2_size
	$DestFlashText.rect_size.x = orig_text_size
	$DestFlashText.scroll_active = false
	set_text('Drop me off at [b]' + point.point_name + '[/b] in [b]%d[/b] seconds please!' % travel_distance)

const speedy_time_text = [
	'so fast!!',
	'that took no time!!'
]
const fast_time_text = [
	'that was fast!',
	'thank you so much!',
	'quick as you like!'
]
const timely_time_text = [
	'right on time!',
	'perfect timing!'
]
const tardy_time_text = [
	'got there in the end',
	'better late than never',
]
const sluggish_time_text = [
	'that took a while',
	'I have aged significantly',
	'where am I? what year is it?'
]

func on_new_dropoff(dropoff, travel_time, travel_score):
	flash()
	var text_choice : Array
	
	match travel_score:
		GameState.JourneyScore.SPEEDY:
			text_choice = speedy_time_text
		GameState.JourneyScore.FAST:
			text_choice = fast_time_text
		GameState.JourneyScore.TIMELY:
			text_choice = timely_time_text
		GameState.JourneyScore.TARDY:
			text_choice = tardy_time_text
		GameState.JourneyScore.SLUGGISH:
			text_choice = sluggish_time_text

	var timeliness = text_choice[randi() % text_choice.size()]
	$ColorRect.rect_size.x += 180
	$ColorRect2.rect_size.x += 180
	$DestFlashText.rect_size.x += 180
	$DestFlashText.scroll_active = false
	set_text('Reached [b]%s[/b] in [b]%d[/b]s, %s' % [dropoff.point_name, travel_time, timeliness])
