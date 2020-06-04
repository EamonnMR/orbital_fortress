extends HBoxContainer

signal list_item_changed(player_id, key, new_value)
signal remove_player(player_id)

var player_id = null

func _ready():
	print("Ship Choice Ready")
	$ship_choice.add_item("Fighter")
	$ship_choice.add_item("Destroyer")
	$ship_choice.add_item("Cruiser")
	
func set_attributes(attributes, is_bot):
	print(self)
	print($ship_choice)
	print("Setting attr")
	print("Get Item count: ", $ship_choice.get_item_count ( ) )
	print("Get selected id: ", $ship_choice.get_selected_id())
	print("Set Attributes")
	player_id = attributes["id"]
	$is_bot.pressed = is_bot
	$name.text = attributes["name"]
	$ship_choice.select(attributes["ship_choice"])
	print($ship_choice.selected)

func _on_ship_choice_item_selected(id):
	print(self)
	print($ship_choice)
	print("Emitting list item changed")
	print("Id selected in signal: ", id)
	print("selected id: ", $ship_choice.get_selected_id())
	print("Get Item count in callback: ", $ship_choice.get_item_count ( ) )
	# emit_signal("list_item_changed", player_id, "ship_choice", id)


func _on_remove_pressed():
	emit_signal("remove_player", player_id)
