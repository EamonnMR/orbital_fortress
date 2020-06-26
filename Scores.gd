extends Node2D

func _process(delta):
	$team0score/ProgressBar.value = gamestate.teams[0]["score"]
	$team0score/score.text = str(gamestate.teams[0]["score"])
	$team1score/ProgressBar.value = gamestate.teams[1]["score"]
	$team1score/score.text = str(gamestate.teams[1]["score"])
