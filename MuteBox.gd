extends CheckBox

func _toggled(button_pressed: bool) -> void:
	AudioServer.set_bus_mute(0, button_pressed)
