extends Control

var parent

func _ready():
	parent = get_node("../")
	$ProgressBar.max_value = parent.max_health
	$ProgressBar.min_value = 0

func _process(delta):
	$ProgressBar.value = parent.health
