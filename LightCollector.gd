extends CenterContainer


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			BuildController.begin_build(BuildController.BuildType.COLLECTOR)
			accept_event()
