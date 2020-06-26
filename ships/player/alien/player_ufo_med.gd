extends "res://player.gd"

func _handle_acceleration(delta):
	return _handle_acceleration_inertialess(delta)

func _init():
	max_speed = 170;
	accel = 60;
