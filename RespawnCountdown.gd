extends Tween

const COUNTDOWN_RATE = 1

signal completed

# Called when the node enters the scene tree for the first time.
func _ready():
	interpolate_property($Center/ProgressBar, "value",
		$Center/ProgressBar.max_value,
		$Center/ProgressBar.min_value,
		COUNTDOWN_RATE,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	start()

func _on_RespawnCountdown_tween_completed():
	emit_signal("completed")
	queue_free()
