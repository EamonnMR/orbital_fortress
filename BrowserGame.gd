extends HBoxContainer

signal join_game(game)

var player_id = null
var game = {}
	
func apply_game(applied_game):
	game = applied_game
	$Name.text = game["name"]
	$IP.text = game["address"]


func _on_Button_pressed():
	emit_signal("join_game", game)
