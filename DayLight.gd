extends Light2D

var sun_enabled := true

func _process(delta: float) -> void:
	if GameState.night_mode && sun_enabled:
		sun_enabled = false
		var tween = create_tween()
		tween.tween_property(self, "texture_scale", 0.0, 0.5)
	
	if !GameState.night_mode && !sun_enabled:
		sun_enabled = true
		var tween = create_tween()
		tween.tween_property(self, "texture_scale", 5.0, 0.5)
