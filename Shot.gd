extends Area2D

const MOVE_SPEED = 275
const DAMAGE = 20
var from_player
var team

func _process(delta):
	position += delta * Vector2(0, -1 * MOVE_SPEED).rotated($Sprite.rotation)

func set_direction(rotation):
	$Sprite.rotation = rotation

func _on_Shot_body_entered(body):
	if qualify_hit(body):
		hit_target(body)
		
func qualify_hit(body):
	print("Try to collide: ", body, "team: ", team, ", body.team: ", body.team, ", from_player: ", from_player, ", body.name: ", body.name)
	return body.name != str(from_player) and body.team != team

func hit_target(target):
	if is_network_master():
		if target.has_method("take_damage"):
			# TODO: Local version of take damage... worth it?
			target.rpc("take_damage", from_player, DAMAGE)
	queue_free()
	# TODO: Sweet explosion
