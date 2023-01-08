extends Sprite


func _ready() -> void:
	BuildController.connect("build_state", self, "_build_state_update")
	modulate = Color.transparent


func _build_state_update(building: bool) -> void:
	var tween = create_tween()
	if building:
		tween.tween_property(self, "modulate", Color("79fe0000"), 0.3)
	else:
		tween.tween_property(self, "modulate", Color.transparent, 0.3)
