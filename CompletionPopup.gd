extends AcceptDialog

func journeys_end(completion_time):
	popup()
	var message = []
	if completion_time > 3600:
		message.append('%d hours' % int(completion_time / 3600))
		completion_time = completion_time % 3600
	if completion_time > 60:
		message.append('%d minutes' % int(completion_time / 3600))
		completion_time = completion_time % 60
	message.append('%d seconds' % int(completion_time))
	$AdiosText.bbcode_text = $AdiosText.bbcode_text.replace('XXX', ' '.join(message))
