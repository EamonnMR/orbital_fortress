extends Area2D

const MOVE_SPEED = 10
var from_player

func _process(delta):
	position += Vector2(0, -1 * MOVE_SPEED).rotated($Sprite.rotation)


func _on_Shot_area_entered(area):
	if area.is_in_group("asteroid"):
		queue_free()

func set_direction(rotation):
	$Sprite.rotation = rotation
