extends KinematicBody2D

export var max_speed = 100;
export var accel = 50;
export var turn_rate = 0.5;

export var team = 0
var health = 25
var max_health = 25
var velocity = Vector2()

var target = null
var rotation_impulse = 0.0

puppet var puppet_pos = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0.0
puppet var puppet_health = 0

func _ready():
	health = max_health
	$sprite/Sprite.frame = team
	
func _physics_process(delta):
	if is_network_master():
		_handle_ai(delta)
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

sync func destroyed():
	print("Mook Destroyed")
	queue_free()
	
master func take_damage(_by_who, amount):
	health -= amount
	if(health) <= 0:
		rpc("destroyed")

func distance_comparitor(lval, rval):
	var ldist = lval.position.distance_to(self.position)
	var rdist = rval.position.distance_to(self.position)
	return ldist < rdist

func _find_target():
	var players = get_node("../../Players").get_children()
	players.sort_custom(self, "distance_comparitor")
	for player in players:
		if player.team != team:
			return player
	return null

func _handle_rotation(delta):
	# TODO: Rotate to face target
	$sprite/Sprite.rotation = fmod($sprite/Sprite.rotation + rotation_impulse, PI * 2) # += rotation_impulse * turn_rate * delta

func _handle_shooting():
	pass
	# TODO: If target in range and can_shoot, do the shooting thing

func _constrained_point(max_turn, position):
	# Get ideal turn for a given point-to position and limited turn amount
	
	# TODO: Sometimes it's taking the long way 'round. Don't do that.
	
	var ideal_face = fmod(get_angle_to(target.position) + PI / 2, PI * 2) # TODO: Global Position?
	var ideal_turn = fmod(ideal_face - $sprite/Sprite.rotation, PI * 2)
	if(ideal_turn > PI):
		ideal_turn = fmod(ideal_turn - 2 * PI, 2 * PI)

	elif(ideal_turn < -1 * PI):
		ideal_turn = fmod(ideal_turn + 2 * PI, 2 * PI)

		
	health = floor(abs((25 * ideal_turn / (2 * PI)) ))
	
	max_turn = sign(ideal_turn) * max_turn  # Ideal turn in the right direction
	
	if(sign(max_turn) == sign(ideal_turn)):
		$sprite/Sprite.frame = 0
	else:
		$sprite/Sprite.frame = 1
	
	if(abs(ideal_turn) > abs(max_turn)):
		return max_turn
	else:
		return ideal_turn

func _handle_ai(delta):
	if not target:
		target = _find_target()
	rotation_impulse = 0.0
	if(target):
		rotation_impulse = _constrained_point(turn_rate * delta, target.position)
		
func _handle_acceleration(delta):
	# TODO: Always accelerate? Or at least always accel if joust = true or distance > engagement dist
	pass

func _limit_speed():
	pass
