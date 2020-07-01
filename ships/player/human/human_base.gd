extends "res://ships/player/player.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var base_frame = 0
var sub_frame = 0
var toggle_engine = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	base_frame = $sprite/Sprite.frame


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	if toggle_engine == 1:
		toggle_engine = 2
	else:
		toggle_engine = 1

func _process(delta):
	if frame_rotation < 0:
		sub_frame = 3
	elif frame_rotation > 0:
		sub_frame = 6
	else:
		sub_frame = 0
	
	$sprite/Sprite.frame = base_frame + sub_frame + (toggle_engine if is_thrusting else 0)
