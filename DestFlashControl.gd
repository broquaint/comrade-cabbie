extends Control

signal repeat_message(msg)

func _ready():
	connect('repeat_message', $'../MessageLog', 'on_message')

func reset():
	$'../FlashAnimationPlayer'.stop()

func flash():
	var player = $'../FlashAnimationPlayer'
	if $'../FlashAnimationPlayer'.is_playing():
		reset()
	player.play("DestFlash")

func set_text(text):
	$DestFlashText.bbcode_text = text

func on_asteroid_change(_from, to):
	flash()
	set_text("Now entering the [b]%s[/b] Asteroid!" % to)

func on_new_pickup(point: DropoffPoint, travel_distance: int):
	flash()

	var text = point.announce_msg(travel_distance)
	set_text(text)
	emit_signal('repeat_message', text)

const speedy_time_text = [
	'so fast!!',
	'that took no time!!',
	'you really know your way around!!',
	'that was some fine driving!!'
]
const fast_time_text = [
	'that was fast!',
	'thank you so much!',
	'quick as you like!',
	'got here in a jiffy!'
]
const timely_time_text = [
	'right on time!',
	'perfect timing!',
	'not a moment too soon!',
	'that was a pleasant journey',
]
const tardy_time_text = [
	'got there in the end',
	'better late than never',
	'that was a good excuse for a nap',
]
const sluggish_time_text = [
	'that took longer than I though',
	'we live to see another day',
	"maybe I'll walk next time",
	'was that the scenic route?'
]

func on_new_dropoff(dropoff, _asteroid, travel_time, travel_score):
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
	var text = 'Reached [b]%s[/b] in [b]%d[/b]s, %s' % [dropoff.point_name, travel_time, timeliness]
	set_text(text)
	emit_signal('repeat_message', text)
