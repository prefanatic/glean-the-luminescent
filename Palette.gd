extends Node

export var color_a: Color
export var color_b: Color
export var color_c: Color


export var player_sample_a := 0.0
export var player_sample_b := 0.0

export var background_sample_a := 0.0
export var background_sample_b := 0.0

export var accent_sample_a := 0.0
export var accent_sample_b := 0.0

export var apply_path: NodePath

var time_based_color: Color


func _ready() -> void:
	apply()
	GameState.connect("game_active_update", self, "_on_game_state_update")
	GameState.connect("mode_update", self, "_on_mode_update")
	BuildController.connect("building_placed", self, "_on_building_placed")


func _on_game_state_update() -> void:
	apply()
	

func _on_building_placed() -> void:
	apply()


func _on_mode_update(night_mode: bool) -> void:
	if !night_mode:
		return
	var tween = create_tween()
	var color = time_color_a(Time.get_unix_time_from_system())
	tween.tween_property(self, "time_based_color", color, 1.0)
	apply()


func _process(delta: float) -> void:
	apply()


func apply_to_node(node: Node) -> void:
	if node is KinematicBody2D:
		if node.sprite != null:
			node.sprite.modulate = player()
	
	if node.name == "Background":
		node.modulate = background()
		
	if node.name == "LightResource":
		if node.sprite != null:
			if GameState.night_mode:
				node.sprite = accent()
			else:
				node.sprite = accent()
	
	if node.name == "TowerLaser":
		node.default_color = accent()

	for child in node.get_children():
		apply_to_node(child)


func apply() -> void:
	if !has_node(apply_path):
		return
		
	var node = get_node(apply_path)
	for child in node.get_children():
		apply_to_node(child)


func player(a: float = 0.0, b: float = 0.0) -> Color:
	return sample_color(player_sample_a + a, player_sample_b + b)


func background() -> Color:
	var b = color_b
	if time_based_color:
		b = time_based_color
	return sample_color(background_sample_a, background_sample_b, color_a, b, color_b)


func accent(a: float = 0.0, b: float = 0.0) -> Color:
	return sample_color(accent_sample_a + a, accent_sample_b + b)


# https://shahriyarshahrabi.medium.com/procedural-color-algorithm-a37739f6dc1
func time_color_a(t: float) -> Color:
	return Color(abs(cos(t+12)+sin(t*0.7+71.124)*0.5),abs(cos(t)+sin(t*0.8+41)*0.5),abs(cos(t+61)+sin(t*0.8+831.32)*0.5));


func sample_color(r1: float, r2: float, color1: Color = color_a, color2: Color = color_b, color3: Color = color_c) -> Color:
	var color1_rgb = Vector3(color1.r, color1.g, color1.b)
	var color2_rgb = Vector3(color2.r, color2.g, color2.b)
	var color3_rgb = Vector3(color3.r, color3.g, color3.b)
	
	var vec = (1-sqrt(r1))*color1_rgb+(sqrt(r1)*(1-r2))*color2_rgb+(r2*sqrt(r1))*color3_rgb;
	return Color(vec.x, vec.y, vec.z)
