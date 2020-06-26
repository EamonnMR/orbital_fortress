extends KinematicBody2D

export var max_speed = 170;
export var accel = 75;
export var turn_rate = 3;
export var points_reward = 50

var basic_shot = preload("res://Shot.tscn")

var velocity = Vector2()
var can_shoot = true
var player_id
var max_health = 100
var health
var inertialess_speed = 0
var team = null

puppet var puppet_pos = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0.0
puppet var puppet_health = 0

# Use sync because it will be called everywhere

sync func shoot(name, pos, direction, by_who):
	var shot = basic_shot.instance()
	shot.set_name(name) # Ensure unique name for the shot
	shot.team = team
	shot.position = pos
	shot.set_direction(direction)
	shot.from_player = by_who
	shot.velocity = velocity
	# No need to set network master to bomb, will be owned by server by default
	get_node("../..").add_child(shot)

var prev_bombing = false
var bomb_index = 0

func _limit_speed():
	if velocity.length() > max_speed:
		velocity = Vector2(cos(velocity.angle()), sin(velocity.angle())) * max_speed

func _facing():
	return fmod((2 * PI) + fmod($sprite.rotation, PI *2), PI *2)

func _handle_shooting():
	if(
		can_shoot and Input.is_key_pressed(KEY_SPACE)
	):
		can_shoot = false
		$reload_timer.start()
		
		var name = get_name() + str(bomb_index)
		rpc("shoot", name, position, $sprite.rotation, get_tree().get_network_unique_id())

		

func _rotate_to_cancel_velocity():
	# TODO: Debug this so it works
	var facing = _facing()
	var ideal_facing = velocity.angle() - PI
	print("Facing")
	print(facing)
	print("ideal Facing")
	print(ideal_facing)
	var difference = fmod(ideal_facing - facing, 2 * PI)
	print("difference")
	print(difference)
	print("Verdict")
	if difference > 0:
		print("right")
		return 1
	if difference < 0:
		print("left")
		return -1
	print("None")
	return 0
	
func _handle_rotation(delta):
	var rotation = 0
	if Input.is_action_pressed("move_left"):
		rotation = -1
	if Input.is_action_pressed("move_right"):
		rotation = 1
	#if Input.is_action_pressed("move_down"):
	#	#rotation = _rotate_to_cancel_velocity()

	$sprite.rotation += rotation * turn_rate * delta

func _handle_acceleration(delta):
	if Input.is_action_pressed("move_up"):
		velocity += Vector2(0, -1 * accel * delta).rotated($sprite.rotation)

func _handle_acceleration_inertialess(delta):
	# Replace the above func with a call to this one if you want an inertialess ship
	if Input.is_action_pressed("move_up"):
		inertialess_speed += accel * delta
	if Input.is_action_pressed("move_down"):
		inertialess_speed -= accel * delta
	
	if inertialess_speed < 0:
		inertialess_speed = 0
	elif inertialess_speed > max_speed:
		inertialess_speed = max_speed
	
	velocity = Vector2(0, -1 * inertialess_speed).rotated($sprite.rotation)
func _push_vars_to_net():
		rset("puppet_velocity", velocity)
		rset("puppet_pos", position)
		rset("puppet_rotation", $sprite.rotation)
		rset("puppet_health", health)

func _get_vars_from_net():
	position = puppet_pos
	velocity = puppet_velocity
	$sprite.rotation = puppet_rotation
	health = puppet_health

func _physics_process(delta):
	if is_network_master():

		_handle_rotation(delta)
		_handle_acceleration(delta)
		_limit_speed()
		_handle_shooting()
		_push_vars_to_net()
	else:
		_get_vars_from_net()

	move_and_slide(velocity)
	if not is_network_master():
		puppet_pos = position # To avoid jitter

sync func destroyed():
	print("Destroyed: ", name)
	gamestate.add_score(gamestate.other_team(team), points_reward)
	queue_free()
	if is_network_master():
		gamestate.add_respawn_timer()

master func take_damage(_by_who, amount):
	health -= amount
	if(health) <= 0:
		rpc("destroyed")

func set_player_name(new_name):
	get_node("label").set_text(new_name)

func _ready():
	health = max_health
	puppet_pos = position

	if (is_network_master()):
		$Camera2D.make_current()


func _on_reload_timer_timeout():
	can_shoot = true
