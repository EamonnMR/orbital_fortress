extends Area2D

export var team = 0
var health = 100

func _ready():
	print("Starbase init")
	$Sprite.frame = team

master func take_damage(_by_who, amount):
	health -= amount
	if(health) <= 0:
		rpc("destroyed")

sync func destroyed():
	print("Destroyed: ", name)
	queue_free()
