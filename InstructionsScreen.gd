extends Control


func _ready() -> void:
	$Back.connect("pressed", self, "_on_back_pressed")


func _on_back_pressed() -> void:
	var start = $"../StartScreen"
	start.modulate = Color.transparent
	start.visible = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.transparent, 0.3)
	tween.tween_property(start, "modulate", Color.white, 0.3)
	tween.tween_property(self, "visible", false, 0.0)
