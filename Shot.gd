extends Area2D

var move_speed = 275
var damage = 20
var from_player
var team
var velocity = Vector2()

func _ready():
	velocity += Vector2(0, -1 * move_speed).rotated($Sprite.rotation)

func _process(delta):
	position += delta * velocity

func set_direction(rotation):
	$Sprite.rotation = rotation

func _on_Shot_body_entered(body):
	if qualify_hit(body):
		hit_target(body)
		
func qualify_hit(body):
	return body.name != str(from_player) and body.team != team

func hit_target(target):
	if is_network_master():
		if target.has_method("take_damage"):
			# TODO: Local version of take damage... worth it?
			target.rpc("take_damage", from_player, damage)
	queue_free()
	# TODO: Sweet explosion
