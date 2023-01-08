extends Control


func _ready() -> void:
	$Button.connect("pressed", self, "_on_button_start")
	$Instructions.connect("pressed", self, "_on_instructions_pressed")


func _on_button_start() -> void:
	GameState.start()
	visible = false


func _on_instructions_pressed() -> void:
	var instructions = $"../InstructionsScreen"
	instructions.modulate = Color.transparent
	instructions.visible = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.transparent, 0.3)
	tween.tween_property(instructions, "modulate", Color.white, 0.3)
