extends KinematicBody2D

signal picking_up(current_pickup)
signal new_pickup(current_dropoff, travel_distance)
signal new_dropoff(dropoff, travel_time, travel_estimate)
signal compass_update(direction, type)
signal distance_update(distance)
signal travel_time_update(travel_time)

signal pickup_interrupted()

const ROTATION_SPEED : float = 4.75 * 60
const BOOST_ROTATION_SPEED : float = 2.75 * 60
const FLOAT_ROTATION_SPEED : float = 5.5 * 60

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
var current_pickup : PickupPoint
var current_dropoff : DropoffPoint
var current_state = CabState.CRUISING
var travel_time : int

func initialize():
	velocity = Vector2.ZERO
	rotation_degrees = 90.0

	boost_level = BoostLevel.NONE
	current_pickup  = null
	current_dropoff = null
	current_state = CabState.CRUISING
	travel_time = 0

	$Decelerating.stop()
	$Exhaust.emitting = false
	$BoostExhaust.emitting = false

	position = GameState.current_asteroid.start_position
	set_next_pickup(GameState.current_asteroid)

func picking_up():
	return current_state == CabState.PICKING_UP
func dropping_off():
	return current_state == CabState.DROPPING_OFF
func boosting():
	return boost_level != BoostLevel.NONE

func _process(_delta):
	var compass_type = 'dropoff' if dropping_off() else 'pickup'
	emit_signal('compass_update', calc_compass(), compass_type)
	emit_signal('distance_update', calc_point_distance())
	if dropping_off():
		emit_signal('travel_time_update', calc_travel_time())

	if floor(velocity.length()) > 0:
		if not boosting():
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
	get_node("../HUD/Control/Container/Speed").bbcode_text = "[b]%d[/b]m/s (%.2f)" % [int(velocity.length() / 8), rotation_degrees]

func _physics_process(delta):
	if Input.is_action_pressed("action_button") and $Flipper/Cooldown.is_stopped():
		var to = rotation_degrees - 180.0
		var flip = $Flipper
		flip.interpolate_property(
			self, 'rotation_degrees', rotation_degrees, to, 0.44,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		flip.start()
		$Flipper/Cooldown.start(0.88)
	elif not $Flipper.is_active():
		var rotation_speed = ROTATION_SPEED
		if boosting():
			rotation_speed = BOOST_ROTATION_SPEED
		elif not Input.is_action_pressed("move_up"):
			rotation_speed = FLOAT_ROTATION_SPEED

		if Input.is_action_pressed("move_left"):
			rotation_degrees -= delta * rotation_speed
		elif Input.is_action_pressed("move_right"):
			rotation_degrees += delta * rotation_speed

		if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
			# TODO Round to nearest X
			rotation_degrees -= fmod(rotation_degrees, 10.0)

	# get acceleration if thrust is pressed
	if Input.is_action_pressed("move_up"):
		if not $ShipSound.playing:
			$ShipSound.vroom(boost_level)
		var acceleration : Vector2

		# -THRUST because vector pointing up = y value of -1, and
		# rotated() method of Vector2 needs a radian, not degrees,
		# so convert that using deg2rad
		var thrust = THRUSTS[boost_level]
		acceleration = Vector2(0, -thrust).rotated(deg2rad(rotation_degrees))

		# add acceleration to current speed
		velocity += acceleration

		# dampen a bit so acceleration feels reasonable
		velocity *= 0.98
	# Begin immediate decelerating if no longer thrusting.
	else:
		if boosting():
			now_decelerating()
		$ShipSound.stop()
		# dampen a bit, but lighter than when accelerating so the ship drifts
		velocity *= 0.985

	# cap speed
	var max_speed = MAX_SPEEDS[boost_level]
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	var collision = move_and_collide(velocity * delta)
	if collision:
		var bounce_ratio = clamp(velocity.length() / max_speed, 0.0, 0.68)
		velocity = velocity.bounce(collision.normal) * bounce_ratio
#		if collision.collider.has_method("hit"):
#			collision.collider.hit()	

func _ready():
# warning-ignore:return_value_discarded
	$Decelerating.connect('timeout', self, 'now_decelerating')
	$Pickup.stream.loop = false
	$Dropoff.stream.loop = false

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
	$ShipSound.vroom(boost_level)

func find_nearest_pickup(asteroid) -> Area2D:
	var pickups = get_parent().pickups[asteroid.name]
	var closest = pickups[0]
	for pickup in pickups:
		var dist = self.position.distance_to(pickup.real_pos)
		if dist < self.position.distance_to(closest.real_pos):
			closest = pickup
	return closest

func on_asteroid_change(_from, _to):
	if current_state != CabState.PICKING_UP:
		return

	current_pickup.waiting_stopped()

	current_pickup = find_nearest_pickup(GameState.current_asteroid)
	current_pickup.passenger_waiting()
	emit_signal("picking_up", current_pickup)

func set_next_pickup(asteroid):
	current_state = CabState.PICKING_UP
	current_pickup = find_nearest_pickup(asteroid)
	current_pickup.passenger_waiting()
	emit_signal("picking_up", current_pickup)

var all_recent_pickups = {}
func pick_next_dropoff(asteroid):
	if not(asteroid.name in all_recent_pickups):
		all_recent_pickups[asteroid.name] = []
	var recent_pickups = all_recent_pickups[asteroid.name]
	if recent_pickups.size() > 4:
		recent_pickups.pop_back()

	var dropoffs
	var unlocked_asteroids = GameState.unlocked_asteroids()
	var current_asteroid = GameState.current_asteroid.name.replace('Asteroid', '')

	if unlocked_asteroids.has(current_asteroid) and unlocked_asteroids.size() > 1: # and randf() < 0.201:
		var other_asteroid = unlocked_asteroids[randi() % unlocked_asteroids.size()]
		dropoffs = get_parent().dropoffs[other_asteroid + 'Asteroid']
	else:
		dropoffs = get_parent().dropoffs[asteroid.name]

	var dropoff = dropoffs[randi() % dropoffs.size()]
	while dropoff in recent_pickups:
		dropoff = dropoffs[randi() % dropoffs.size()]

	recent_pickups.push_front(dropoff)
	return dropoff

func set_next_dropoff(asteroid):
	$Pickup.play()

	current_state = CabState.DROPPING_OFF
	current_pickup.waiting_stopped()

	current_dropoff = pick_next_dropoff(asteroid)

	current_dropoff.journey_started()
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

func passenger_collected(point : PickupPoint):
	# It's possible to go to alternative pickups.
	current_pickup = point
	set_next_dropoff(point.get_asteroid())
	travel_time = Time.get_ticks_msec()
	current_state = CabState.DROPPING_OFF

func passenger_pickup_missed(point : PickupPoint):
	if picking_up():
		emit_signal('pickup_interrupted', point)

func passenger_deposited(point : DropoffPoint):
	emit_signal('new_dropoff', point, calc_travel_time(), calc_journey_score())

	$Dropoff.play()
	current_dropoff.journey_completed()
	current_state = CabState.PICKING_UP
	travel_time = 0
	# This maybe doesn't want to be instant?
	set_next_pickup(point.get_asteroid())

func passenger_dropoff_missed(_point):
	pass
