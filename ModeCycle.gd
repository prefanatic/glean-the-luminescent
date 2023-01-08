extends Control

func _process(delta: float) -> void:
	visible = GameState.game_running
	
	$ProgressBar.value = GameState.mode_progress() * 100.0
	
	var mode: String
	if GameState.night_mode:
		mode = "Night %d" % GameState.cycles
	else:
		mode = "Day %d" % GameState.cycles
	$ModeLabel.text = mode
