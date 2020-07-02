extends Area2D

export var team = 0
var max_health = 5000
var health
var mook_counter = 0

func _ready():
	health = max_health
	$Sprite.frame = team

master func take_damage(_by_who, amount):
	health -= amount
	if(health) <= 0:
		rpc("destroyed")

sync func destroyed():
	print("Destroyed: ", name)
	queue_free()
	gamestate.team_defeated(team)

func _on_spawn_timer_timeout():
	if is_network_master():
		# TODO: Generate any randomness such as mook position
		rpc("spawn_mooks")

sync func spawn_mooks():
	if len(get_node("../../Mooks").get_children()) < 25:
		for i in range(5):
			var mook = preload("res://ships/mooks/Mook.tscn").instance()
			mook.team = team
			mook.position = position + (Vector2(10, 10) * i)
			mook.set_name("mook_t_" + str(team) + "_id_" + str(mook_counter))
			get_node("/root/World/Viewport/Mooks").add_child(mook)
			get_node("/root/HUD/Radar").add_item(mook)
			mook_counter += 1
