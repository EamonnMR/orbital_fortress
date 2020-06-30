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
	if toggle_engine:
		toggle_engine = 0
	else:
		toggle_engine = 1

func _handle_rotation(delta):
	var rotation = ._handle_rotation(delta)
	if rotation < 0:
		sub_frame = 2
	elif rotation > 0:
		sub_frame = 4
	else:
		sub_frame = 0
	
	$sprite/Sprite.frame = base_frame + sub_frame + toggle_engine
	return rotation
