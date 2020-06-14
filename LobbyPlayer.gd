extends HBoxContainer

signal list_item_changed(player_id, key, new_value)
signal remove_player(player_id)

var player_id = null

func _ready():
	$team_choice.add_item("Team 0")
	$team_choice.add_item("Team 1")
	
	for species in gamestate.player_types.values():
		$ship_choice.add_item(species["name"])
	
func set_attributes(attributes, is_bot):
	print(attributes)
	player_id = attributes["id"]
	$is_bot.pressed = is_bot
	$name.text = attributes["name"]
	$ship_choice.select(attributes["ship_choice"])
	$team_choice.select(attributes["team"])

func _on_ship_choice_item_selected(id):
	emit_signal("list_item_changed", player_id, "ship_choice", id)

func _on_team_choice_item_selected(id):
	emit_signal("list_item_changed", player_id, "team", id)

func _on_remove_pressed():
	emit_signal("remove_player", player_id)
