extends "res://DestPoint.gd"

class_name DropoffPoint

func announce_msg(travel_distance):
	var in_asteroid = ''
	if get_asteroid() != GameState.current_asteroid:
		in_asteroid = ', [b]%s[/b],' % get_asteroid().name.replace('Asteroid', ' Asteroid')
	return 'Drop me off at [b]' + point_name + '[/b]%s in [b]%d[/b] seconds please!' % [in_asteroid, travel_distance]
