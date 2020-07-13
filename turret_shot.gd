extends "res://Shot.gd"

export var max_speed = 90;
export var accel = 30;
export var turn_rate = PI / 3
export var rotation_impulse = 0
export var ideal_face = 0

puppet var puppet_pos = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0.0



var target = null

func _init():
	lifetime = 5

func _physics_process(delta):
	if is_network_master():
		_handle_ai(delta)
		_handle_rotation(delta)
		_handle_acceleration(delta)
		_limit_speed()
		_handle_velocity(delta)
		_push_vars_to_net()
	else:
		_get_vars_from_net()

func _handle_ai(delta):
	if not target or not is_instance_valid(target):
		rpc("end_of_life")
	else:
		rotation_impulse = 0.0
		ideal_face = null
		var impulse = ai._constrained_point(self, target, $Sprite.rotation, turn_rate * delta, target.position)
		rotation_impulse = impulse[0]
		ideal_face = impulse[1]
		
func _handle_acceleration(delta):
	velocity += Vector2(0, -1 * accel * delta).rotated($Sprite.rotation)

func _handle_rotation(delta):
	$Sprite.rotation = fmod($Sprite.rotation + rotation_impulse, PI * 2) # += rotation_impulse * turn_rate * delta

func _limit_speed():
	if velocity.length() > max_speed:
		velocity = Vector2(cos(velocity.angle()), sin(velocity.angle())) * max_speed

func _handle_velocity(delta):
	position += delta * velocity

func _push_vars_to_net():
	rset("puppet_velocity", velocity)
	rset("puppet_pos", position)
	rset("puppet_rotation", $Sprite.rotation)

func _get_vars_from_net():
	position = puppet_pos
	velocity = puppet_velocity
	$Sprite.rotation = puppet_rotation
