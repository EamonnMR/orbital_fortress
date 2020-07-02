extends ColorRect

var tracked_objects = {}

func add_item(tracked_object):
	# TODO: Different kinds of blips
	var blip = preload("res://radar/radar_blip.tscn").instance()
	tracked_objects[tracked_object] = blip
	add_child(blip)

func radar_scale(position):
	# TODO: Scale
	return (position / 25) + get_size() / 2

func _ready():
	for base in get_node("/root/World/Viewport/Bases").get_children():
		add_item(base)

func _process(delta):
	for tracked_object in tracked_objects:
		var blip = tracked_objects[tracked_object]
		if is_instance_valid(tracked_object):
			blip.position = radar_scale(tracked_object.position)
		else:
			tracked_objects.erase(tracked_object)
			blip.queue_free()
