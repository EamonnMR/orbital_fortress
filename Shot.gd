extends Area2D

var move_speed = 275
var damage = 20
var from_player
var team
var velocity = Vector2()
var lifetime = 1

func _ready():
	$lifetime.wait_time = lifetime
	velocity += Vector2(0, -1 * move_speed).rotated($Sprite.rotation)

func _physics_process(delta):
	position += delta * velocity

func set_direction(rotation):
	$Sprite.rotation = rotation

func _on_Shot_body_entered(body):
	if qualify_hit(body):
		hit_target(body)
		
func qualify_hit(body):
	return "health" in body and body.name != str(from_player) and body.team != team

func hit_target(target):
	if is_network_master():
		if target.has_method("take_damage"):
			# TODO: Local version of take damage... worth it?
			target.rpc("take_damage", from_player, damage)
			queue_free()
			# TODO: Sweet explosion


func _on_lifetime_timeout():
	if is_network_master():
		rpc("end_of_life")

sync func end_of_life():
	queue_free()

