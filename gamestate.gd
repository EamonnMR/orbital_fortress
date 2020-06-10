extends Node

# Default game port. Can be any number between 1024 and 49151.
const DEFAULT_PORT = 26000

# Max number of players.
const MAX_PEERS = 12

const HOST_ID = 1 # TODO: might simplify the code if we use 1 here, if 1 is always the ID of the server for RPC

var player_name = "The Warrior"
var world = null

const DEFAULT_SHIP = 1

# Names for remote players in id:{name, id, ship_choice} format
var players = {}
var bots = {}  # TODO: Add bots
var players_ready = []

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree.
func _player_connected(id):
	# From: Network peer connected
	# Signal is triggered on each peer when the server is connected.
	print("network_peer_connected: ", id)
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", _get_player_data())


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id]["name"] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	# var id = get_tree().get_network_unique_id()
	emit_signal("connection_succeeded")

func _get_player_data():
	print(players)
	return players[get_tree().get_network_unique_id()]

# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(data):
	var id = get_tree().get_rpc_sender_id()
	print("sender_id: ", id, "data['id']: ", data["id"])
	_add_player_to_list(id, data["name"], data["ship_choice"])
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")
	
sync func sync_modify_player_attribute(player_id, attr, new_value):
	players[player_id][attr] = new_value
	print("Player attribute modified!  ", players)
	emit_signal("player_list_changed")

	
func modify_player_attribute(player_id, attr, new_value):
	if attr == "id":
		print("Cannot modify ID")
		return
	
	print("Modify Player attribute")
	
	for p in players:
		print("Sync for player", p)
		if(p > 0):  # TODO: Maybe have a function that returns remote players?
			rpc_id(p, "sync_modify_player_attribute", player_id, attr, new_value)
	
		
sync func pre_start_game(spawn_points):
	# Change scene.
	world = load("res://world.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("Lobby").hide()

	for p_id in spawn_points:
		spawn_player(p_id, world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position)

	# Set up score.
	# TODO: Make the score node follow the camera / static

	for pn in players:
		world.get_node("Score").add_player(pn, players[pn]["name"])

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

func spawn_player(id, position):
	# TODO: Load a list of these, switch based on player id
	var player_scene = load("res://player.tscn")
	# TODO: Instance differently based on players[p_id]["ship_choice"]
	var player = player_scene.instance()

	player.set_name(str(id)) # Use unique ID as node name.
	player.position=position
	player.set_network_master(id) #set unique id as master.

	player.set_player_name(players[id]["name"])

	world.get_node("Players").add_child(player)


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!


remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

	# Add your own player to the game
	_add_player_to_list(
		get_tree().get_network_unique_id(),
		new_player_name,
		DEFAULT_SHIP
	)


func join_game(ip, new_player_name):
	player_name = new_player_name
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	
	_add_player_to_list(
		get_tree().get_network_unique_id(),
		new_player_name,
		DEFAULT_SHIP
	)
	
	var player_id = get_tree().get_network_unique_id()
	print("get_network_unique_id: ", player_id)


func get_player_list():
	var names = []
	for value in players.values():
		names.append(value["name"])
	return names


func get_player_name():
	return player_name


func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	# pre_start_game(spawn_points)


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()

func _add_player_to_list(id, name, ship_choice):
	players[id] = {"id": id, "name": name, "ship_choice": ship_choice}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _respawn_player():
	rpc(
		"_sync_respawn_player",
		get_tree().get_network_unique_id()
	)

sync func _sync_respawn_player(id):
	spawn_player(id, Vector2(0,0))

func add_respawn_timer():
	# TODO: Stick this right into world.tscn and show/hide it?
	var timer = preload("res://RespawnCountdown.tscn").instance()
	timer.connect("completed", self, "_respawn_player")	
	world.add_child(timer)
