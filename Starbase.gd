extends Area2D

export var team = 0
var max_health = 100
var health

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
			var mook = preload("res://Mook.tscn").instance()
			mook.team = team
			mook.position = position + (Vector2(10, 10) * i)
			get_node("../../Mooks").add_child(mook)
			get_node("../../../HUD/Radar").add_item(mook)
