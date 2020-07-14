extends Node2D

func _process(delta):
	$team0score/ProgressBar.value = gamestate.teams[0]["score"] % gamestate.LEVEL_UP
	$team0score/score.text = str(gamestate.teams[0]["level"] + 1)
	$team1score/ProgressBar.value = gamestate.teams[1]["score"] % gamestate.LEVEL_UP
	$team1score/score.text = str(gamestate.teams[1]["level"] + 1)
