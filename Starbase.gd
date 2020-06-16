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
