extends Container

const HOVER_COLOR = Color("802e2e")
const DISABLED_COLOR = Color(1.0, 1.0, 1.0, 0.1)

enum BuildType {
	COLLECTOR, TOWER
}

export (BuildType) var build_type: int

var enabled := false
var hovered := false
var rotate_val := 0.0

func _ready() -> void:
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	modulate = DISABLED_COLOR
	GameState.connect("game_active_update", self, "_on_game_state_update")
	GameState.connect("resource_update", self, "_on_resource_update")
	GameState.connect("mode_update", self, "_on_mode_update")
	BuildController.connect("building_placed", self, "_on_building_placed")
	$Cost.text = "(%d)" % BuildController.get_cost(build_type)


func _on_game_state_update() -> void:
	_update()


func _on_building_placed() -> void:
	_update()


func _on_mode_update(night_mode: bool) -> void:
	_update()


func _update() -> void:
	$Cost.text = "(%d)" % BuildController.get_cost(build_type)
	if GameState.night_mode:
		disable_item()
	else:
		_on_resource_update(GameState.core_power)


func _on_mouse_entered() -> void:
	hovered = true
	_update_hover_state()


func _on_mouse_exited() -> void:
	hovered = false
	_update_hover_state()


func _update_hover_state() -> void:
	if enabled && hovered:
		modulate = HOVER_COLOR
	if enabled && !hovered:
		modulate = Color.white


func _on_resource_update(power: int) -> void:
	$Cost.text = "(%d)" % BuildController.get_cost(build_type)
	var can_afford = BuildController.can_afford(build_type)
	
	if can_afford && !enabled:
		enable_item()
	elif !can_afford && enabled:
		disable_item()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			BuildController.begin_build(build_type)
			accept_event()


func enable_item() -> void:
	if GameState.night_mode:
		return
	enabled = true
	
	var pos_x = rect_position.x
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.white, 0.3)
	tween.parallel().tween_property(self, "rect_position", Vector2(pos_x, -6), 0.05)
	tween.tween_property(self, "rect_position", Vector2(pos_x, 0), 0.1)
	yield(tween, "finished")
	_update_hover_state()


func disable_item() -> void:
	enabled = false
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", DISABLED_COLOR, 0.3)
