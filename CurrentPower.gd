extends Label


func _ready() -> void:
	GameState.connect("resource_update", self, "_on_resource_update")
	GameState.connect("game_active_update", self, "_on_game_state_change")
	_on_resource_update(GameState.core_power)


func _on_game_state_change(active: bool) -> void:
	visible = active


func _on_resource_update(power: float) -> void:
	text = "Power: %.1f/50" % power
