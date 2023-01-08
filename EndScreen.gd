extends Control

func _ready() -> void:
	GameState.connect("game_over", self, "_on_game_over")
	$Button.connect("pressed", self, "_on_restart_pressed")


func _on_restart_pressed() -> void:
	GameState.restart()
	visible = false


func _on_game_over() -> void:
	$HBoxContainer/CyclesSurvivedContainer/CyclesSurvivedValue.text = "%d" % GameState.cycles
	$HBoxContainer/LightCollectedContainer/LightCollectedValue.text = "%d" % GameState.total_collected_power
	visible = true
