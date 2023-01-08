extends Node2D
class_name Core


const MAX_LIGHT = 50.0
const MAX_SPRITE_SCALE = Vector2(2.0, 2.0)

var radius := 20

func _ready() -> void:
	GameState.core = self
	GameState.core_position = global_position
	
	$PickupRadius.connect("body_entered", self, "_on_body_entered")
	update_core()


func reset() -> void:
	GameState.core = self
	GameState.core_position = global_position
	update_core()
	$CoreBody/Sprite.modulate = Color.white
	$Light2D.shadow_enabled = true


func do_hit() -> void:
	GameState.decrease_core_power(1.5)


func do_death() -> void:
	GameState.end_game()


func do_win() -> void:
	if !GameState.game_running:
		return
	GameState.win_game()
	yield(get_tree().create_timer(1.5), "timeout")
	
	# Expand!
	var tween = create_tween()
	tween.tween_property($CoreBody/Sprite, "scale", Vector2(60.0, 60.0), 1.0)
	tween.parallel().tween_property($CoreBody/Sprite, "modulate", Color("623535"), 1.0)
	tween.parallel().tween_property($Light2D, "shadow_enabled", false, 0.0).set_delay(0.5)


func update_core() -> void:
	if GameState.core_power >= MAX_LIGHT:
		do_win()
		return
		
	if GameState.core_power <= 0:
		do_death()
		return
		
	var light_scale = GameState.core_power / MAX_LIGHT
	var body_scale = MAX_SPRITE_SCALE * light_scale
	radius = 20 * body_scale.x / 2
	
	var tween = create_tween()
	tween.tween_property($CoreBody/Sprite, "scale", Vector2(0.25, 0.25), 0.3)
	tween.parallel().tween_property($CoreBody, "scale", body_scale, 0.3)
	tween.parallel().tween_property($Light2D, "energy", light_scale + 0.3, 0.3)


func _on_body_entered(node: Node2D) -> void:
	if GameState.night_mode:
		return
		
	if node is Player:
		for child in node.get_children():
			if !is_instance_valid(child):
				continue
			if child is LightResource:
				child.attach_target(self)
				child.attach_core = true
				
				node.dropoff_light()
				yield(get_tree().create_timer(0.15), "timeout")
