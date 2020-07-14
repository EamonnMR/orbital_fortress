extends Area2D

var in_range = []
export var team = 0
var health = 300
var max_health = 300
var target = null
var can_shoot = false
var points_reward = 500

puppet var puppet_health = health
var base_shot = preload("res://turret_shot.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.frame = team * $Sprite.hframes
	
func _physics_process(delta):
	if is_network_master():
		_handle_ai(delta)
		_handle_shooting()
		_push_vars_to_net()
	else:
		_get_vars_from_net()

func _handle_ai(delta):
	if not target or not is_instance_valid(target) or not target in in_range:
		target = _find_target()
	
func _push_vars_to_net():
	rset("puppet_health", health)

func _get_vars_from_net():
	health = puppet_health

func _find_target():
	for node in in_range:
		return node
	return null
	
func _handle_shooting():
	if(
		can_shoot and target
	):
		can_shoot = false
		$reload_timer.start()
		rpc("shoot", "turret shot", position, get_angle_to(target.position) + PI / 2, get_tree().get_network_unique_id())

sync func shoot(name, pos, direction, by_who):
	var shot = base_shot.instance()
	shot.set_name(name) # Ensure unique name for the shot
	shot.team = team
	shot.position = pos
	shot.set_direction(direction)
	shot.target = target
	# No need to set network master to bomb, will be owned by server by default
	get_node("../..").add_child(shot)

func _on_range_body_entered(body):
	if (
		(not body in in_range) and
		(body.team != team) and
		(body.has_method("take_damage"))
	):
		in_range.append(body)

func _on_range_body_exited(body):
	in_range.erase(body)

master func take_damage(_by_who, amount):
	health -= amount
	if(health) <= 0:
		rpc("destroyed")

sync func destroyed():
	gamestate.add_score(gamestate.other_team(team), points_reward)
	queue_free()

func _on_Timer_timeout():
	can_shoot = true
