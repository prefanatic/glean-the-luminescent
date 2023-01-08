extends Control

func _ready() -> void:
	GameState.connect("game_win", self, "_on_game_win")
	$Button.connect("pressed", self, "_on_restart_pressed")


func _on_restart_pressed() -> void:
	GameState.restart()
	visible = false


func _on_game_win() -> void:
	yield(get_tree().create_timer(2.5), "timeout")
	
	$HBoxContainer/CyclesSurvivedContainer/CyclesSurvivedValue.text = "%d" % GameState.cycles
	$HBoxContainer/LightCollectedContainer/LightCollectedValue.text = "%d" % GameState.total_collected_power
	
	modulate = Color.transparent
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.white, 0.8)

