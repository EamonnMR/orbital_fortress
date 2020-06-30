extends "res://ships/player/player.gd"

var animation_frame = 0
var base_frame = 0

func _ready():
	._ready()
	base_frame = $sprite/Sprite.frame

func _on_Timer_timeout():
	animation_frame += 1
	if animation_frame > 3:
		animation_frame = 0
	$sprite/Sprite.frame = animation_frame + base_frame
