extends Control

# TODO: add a signal to the lobby player
# That gets transmitted when they edit
# an attribute. Connect it to a sync or
# remote function on the gamestate which
# checks to make sure it's from the right
# peer ID, and if so, updates the players
# list and (either way) updates the on-screen
# list.

func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]

func _on_host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""

	var player_name = $Connect/Name.text
	gamestate.host_game(player_name)
	refresh_lobby()


func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true

	var player_name = $Connect/Name.text
	gamestate.join_game(ip, player_name)


func _on_connection_success():
	$Connect.hide()
	$Players.show()


func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")


func _on_game_ended():
	show()
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func refresh_lobby():
	# print("Refresh lobby")
	var players = gamestate.players
	_clear_list()
	# print(players)
	for p in players.values():
		_add_lobby_player(p)

	$Players/Start.disabled = not get_tree().is_network_server()


func _on_start_pressed():
	gamestate.begin_game()
	
func _on_add_bot_pressed():
	pass
	# TODO: gamestate.add_bot()
	
func _on_kick_player(player_id):
	print("TODO: Remove player: " + player_id)
	# TODO: gamestate.remove_player(id)

func _on_update_player_config_in_lobby(player_id, attr, value):
	print("_on_update_player_config_in_lobby")
	gamestate.modify_player_attribute(player_id, attr, value)
	
func _clear_list():
	for list in [$Players/List_t0, $Players/List_t1]:
		for n in list.get_children():
			list.remove_child(n)
			n.queue_free()

func _add_lobby_player(player):
	var lobby_player = preload("res://LobbyPlayer.tscn").instance()
	if(player["team"]) == 0:
		$Players/List_t0.add_child(lobby_player)
	if(player["team"]) == 1:
		$Players/List_t1.add_child(lobby_player)
	lobby_player.set_attributes(player, false)
	lobby_player.connect("list_item_changed", self, "_on_update_player_config_in_lobby")
	lobby_player.connect("remove_player", self, "_on_kick_player")
