extends Node2D

func switch_viewport(viewport: Viewport):
	var rtt = viewport.get_texture()
	$WorldSprite.texture = rtt


func _ready():
	$WorldSprite.position = Vector2(
		ProjectSettings.get_setting("display/window/size/width") / 2,
		ProjectSettings.get_setting("display/window/size/height") / 2
	)
	switch_viewport($Viewport)
