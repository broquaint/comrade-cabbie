extends AcceptDialog

var record_regex : RegEx = RegEx.new()

func _ready():
	record_regex.compile('zz(.*)zz')

func secs_to_str(completion_time):
	var message = []
	if completion_time > 3600:
		message.append('%d hours' % int(completion_time / 3600))
		completion_time = completion_time % 3600
	if completion_time > 60:
		message.append('%d minutes' % int(completion_time / 3600))
		completion_time = completion_time % 60
	message.append('%d seconds' % int(completion_time))
	return ' '.join(message)

func journeys_end(completion_time, fastest_time):
	popup()
	var completion_time_str = secs_to_str(completion_time)
	var text = $AdiosText.bbcode_text.replace('XXX', completion_time_str)
	if completion_time == fastest_time:
		$AdiosText.bbcode_text = record_regex.sub(text, '[b]New record![/b]')
	else:
		text = record_regex.sub(text, '$1')
		$AdiosText.bbcode_text = text.replace('YYY', secs_to_str(fastest_time))
