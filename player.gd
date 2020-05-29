extends KinematicBody2D

const MOTION_SPEED = 90.0

var velocity = Vector2()

puppet var puppet_pos = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0.0

export var stunned = false

# Use sync because it will be called everywhere
sync func setup_bomb(bomb_name, pos, by_who):
	var bomb = preload("res://bomb.tscn").instance()
	bomb.set_name(bomb_name) # Ensure unique name for the bomb
	bomb.position = pos
	bomb.from_player = by_who
	# No need to set network master to bomb, will be owned by server by default
	get_node("../..").add_child(bomb)

var current_anim = ""
var prev_bombing = false
var bomb_index = 0

func _physics_process(delta):
	if is_network_master():
		if Input.is_action_pressed("move_left"):
			$sprite.rotation += 100
		if Input.is_action_pressed("move_right"):
			$sprite.rotation -= 100
		if Input.is_action_pressed("move_up"):
			velocity += Vector2(0, -1).rotated($sprite.rotation)

		var bombing = Input.is_action_pressed("set_bomb")

		if stunned:
			bombing = false
			velocity = Vector2()

		if bombing and not prev_bombing:
			var bomb_name = get_name() + str(bomb_index)
			var bomb_pos = position
			rpc("setup_bomb", bomb_name, bomb_pos, get_tree().get_network_unique_id())

		prev_bombing = bombing
		
		rset("puppet_velocity", velocity)
		rset("puppet_pos", position)
		rset("puppet_rotation", $sprite.rotation)
	else:
		position = puppet_pos
		velocity = puppet_velocity
		$sprite.rotation = puppet_rotation

	move_and_slide(velocity)
	if not is_network_master():
		puppet_pos = position # To avoid jitter

puppet func stun():
	stunned = true

master func exploded(_by_who):
	if stunned:
		return
	rpc("stun") # Stun puppets
	stun() # Stun master - could use sync to do both at once

func set_player_name(new_name):
	get_node("label").set_text(new_name)

func _ready():
	stunned = false
	puppet_pos = position

	if (is_network_master()):
		$Camera2D.make_current()
