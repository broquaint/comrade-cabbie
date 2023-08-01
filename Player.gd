extends KinematicBody2D

signal picking_up(current_pickup)
signal new_pickup(current_dropoff, travel_distance)
signal new_dropoff(dropoff, travel_time, travel_estimate)
signal compass_update(direction, type)
signal distance_update(distance)
signal travel_time_update(travel_time)

const ROTATION_SPEED : float = 6.0 * 60

enum CabState {
	CRUISING, # Not implemented yet
	PICKING_UP,
	DROPPING_OFF
}

enum BoostLevel {
	NONE,
	SOME,
	SPEEDY,
	LUDICROUS
}

const THRUSTS = [
	12.0, # NONE
	14.0, # SOME
	17.0, # SPEEDY
	21.0, # LUDICROUS
]

const MAX_SPEEDS = [
	600.0, # NONE
	630.0, # SOME
	670.0, # SPEEDY
	720.0, # LUDICROUS
]

var boost_level = BoostLevel.NONE

var velocity : Vector2
var current_pickup : Area2D
var current_dropoff : Area2D
var current_state = CabState.CRUISING
var travel_time : int

func picking_up():
	return current_state == CabState.PICKING_UP
func dropping_off():
	return current_state == CabState.DROPPING_OFF

func _process(_delta):
	var compass_type = 'dropoff' if dropping_off() else 'pickup'
	emit_signal('compass_update', calc_compass(), compass_type)
	emit_signal('distance_update', calc_point_distance())
	if dropping_off():
		emit_signal('travel_time_update', calc_travel_time())

	if floor(velocity.length()) > 0:
		if boost_level == BoostLevel.NONE:
			$Exhaust.emitting  = true
			$Exhaust.gravity.y = (velocity.length() / MAX_SPEEDS[boost_level]) * 100
			$BoostExhaust.emitting = false
		else:
			$BoostExhaust.emitting  = true
			$BoostExhaust.gravity.y = (velocity.length() / MAX_SPEEDS[boost_level]) * 100
			$Exhaust.emitting = false
	else:
		$Exhaust.emitting = false
		$BoostExhaust.emitting = false

	# Hack!
	get_node("../HUD/Control/Container/Speed").bbcode_text = "[b]%.2f[/b]m/s (%.2f)" % [velocity.length(), $Exhaust.gravity.y]

func _physics_process(delta):
	if Input.is_action_pressed("move_left"):
		rotation_degrees -= delta * ROTATION_SPEED
	elif Input.is_action_pressed("move_right"):
		rotation_degrees += delta * ROTATION_SPEED

	# get acceleration if thrust is pressed
	if Input.is_action_pressed("move_up"):
		var acceleration : Vector2

		# -THRUST because vector pointing up = y value of -1, and
		# rotated() method of Vector2 needs a radian, not degrees,
		# so convert that using deg2rad
		var thrust = THRUSTS[boost_level]
		acceleration = Vector2(0, -thrust).rotated(deg2rad(rotation_degrees))

		# add acceleration to current speed
		velocity += acceleration
	# Begin immediate decelerating if no longer thrusting.
	elif boost_level != BoostLevel.NONE:
		now_decelerating()

	# dampen a bit
	velocity *= 0.98

	# cap speed
	var max_speed = MAX_SPEEDS[boost_level]
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	velocity = move_and_slide(velocity)

func _ready():
	$Decelerating.connect('timeout', self, 'now_decelerating')

func now_decelerating():
	match boost_level:
		BoostLevel.LUDICROUS:
			boost_level = BoostLevel.SPEEDY
		BoostLevel.SPEEDY:
			boost_level = BoostLevel.SOME
		BoostLevel.SOME:
			boost_level = BoostLevel.NONE
	if boost_level != BoostLevel.NONE:
		$Decelerating.start(0.5)

func boost_entered(_node):
	# Doesn't need to be a match but this makes it easy for me to reckon with.
	match boost_level:
		BoostLevel.NONE:
			boost_level = BoostLevel.SOME
		BoostLevel.SOME:
			boost_level = BoostLevel.SPEEDY
		BoostLevel.SPEEDY:
			boost_level = BoostLevel.LUDICROUS
	$Decelerating.start(1.0)

func find_nearest_pickup(asteroid) -> Area2D:
	var pickups = get_parent().pickups[asteroid.name]
	var closest = pickups[0]
	for pickup in pickups:
		var dist = self.position.distance_to(pickup.real_pos)
		if dist < self.position.distance_to(closest.real_pos):
			closest = pickup
	return closest

func set_next_pickup(asteroid):
	current_state = CabState.PICKING_UP
	current_pickup = find_nearest_pickup(asteroid)
	current_pickup.get_node('AnimationPlayer').play('Pulse')
	current_pickup.get_node('Point Pulse').visible = true
	emit_signal("picking_up", current_pickup)

func set_next_dropoff(asteroid):
	current_state = CabState.DROPPING_OFF
	current_pickup.get_node('AnimationPlayer').stop()
	current_pickup.get_node('Point Pulse').visible = false
	var dropoffs = get_parent().dropoffs[asteroid.name]
	current_dropoff = dropoffs[randi() % dropoffs.size()]
	current_dropoff.get_node('AnimationPlayer').play('Pulse')
	current_dropoff.get_node('Point Pulse').visible = true
	emit_signal('new_pickup', current_dropoff, calc_travel_estimate(current_pickup, current_dropoff))

func calc_point_distance():
	var point = current_dropoff if current_state == CabState.DROPPING_OFF else current_pickup
	var dist = self.position.distance_to(point.real_pos)
	return int(dist / 8)

func calc_compass():
	var point = current_dropoff if current_state == CabState.DROPPING_OFF else current_pickup
	var diff = self.position - point.real_pos
	var is_v = abs(diff.y) > abs(diff.x)
	if is_v:
		return 'north' if diff.y > 0 else 'south' 
	else	:
		return 'west' if diff.x > 0 else 'east'

func calc_travel_estimate(a, b):
	var dist = int(a.real_pos.distance_to(b.real_pos) / 8)
	# Add 25% for buffer.
	return clamp(1.25 * (dist / 20), 5, 600)

func calc_travel_time():
	return float(Time.get_ticks_msec() - travel_time) / 1000

func calc_journey_score():
	var tt = calc_travel_time()
	var travel_estimate =  calc_travel_estimate(current_pickup, current_dropoff)
	var score = tt / travel_estimate
	if score <= 0.6:
		return GameState.JourneyScore.SPEEDY
	elif score <= 0.80:
		return GameState.JourneyScore.FAST
	elif score <= 1.2:
		return GameState.JourneyScore.TIMELY
	elif score <= 1.4:
		return GameState.JourneyScore.TARDY
	else:
		return GameState.JourneyScore.SLUGGISH

func pickup_point_entered(_node, point, asteroid):
	if picking_up():
		# It's possible to go to alternative pickups.
		current_pickup = point
		set_next_dropoff(asteroid)
		travel_time = Time.get_ticks_msec()
		current_state = CabState.DROPPING_OFF

func dropoff_point_entered(_node, point, asteroid):
	if point == current_dropoff and dropping_off():
		# Not in use at the moment.
		emit_signal('new_dropoff', point, calc_travel_time(), calc_journey_score())
		current_dropoff.get_node('AnimationPlayer').stop()
		current_dropoff.get_node('Point Pulse').visible = false
		current_state = CabState.PICKING_UP
		travel_time = 0
		# This maybe doesn't want to be instant?
		set_next_pickup(asteroid)
