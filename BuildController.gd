extends Node

const DEBOUNCE_TIME = 0.3

const CORE_BUFFER = 100
const DISABLED_COLOR = Color(1.0, 1.0, 1.0, 0.1)

enum BuildType {
	COLLECTOR, TOWER
}

onready var build_sound := preload("res://building.wav")
onready var collector := preload("res://Collector.tscn")
onready var tower := preload("res://Tower.tscn")

var node: Node2D
var hovering_build := -1
var drop_press_debounce := false
var drop_time_debounce := 0.0

signal building_placed
signal build_state

func _count_collectors() -> int:
	var count = 0
	var nodes = get_tree().get_nodes_in_group("buildings")
	for node in nodes:
		if node is Collector:
			count += 1
	return count


func _collect_towers() -> int:
	var count = 0
	var nodes = get_tree().get_nodes_in_group("buildings")
	for node in nodes:
		if node is Tower:
			count += 1
	return count


func get_cost(build_type) -> int:
	match build_type:
		BuildType.COLLECTOR:
			return 5 + (_count_collectors() * 5)
		BuildType.TOWER:
			return 10 + (_collect_towers() * 5)
	return -1


func can_afford(build_type) -> bool:
	return get_cost(build_type) < GameState.core_power


func begin_build(build_type) -> void:
	if GameState.night_mode:
		return
	if !can_afford(build_type):
		return
		
	var time = Time.get_unix_time_from_system()
	AudioService.play(build_sound, 1.5, -5.0)
	GameState.decrease_core_power(get_cost(build_type))
	drop_time_debounce = time + DEBOUNCE_TIME
	
	hovering_build = build_type
	match hovering_build:
		BuildType.COLLECTOR:
			node = collector.instance()
		BuildType.TOWER:
			node = tower.instance()
	node.building_enabled = false
	get_tree().current_scene.add_child(node)
	emit_signal("build_state", true)


func end_build() -> void:
	var time = Time.get_unix_time_from_system()
	if time < drop_time_debounce:
		return
	var dist = node.global_position - GameState.core_position
	if dist.length() < CORE_BUFFER:
		return
		
	AudioService.play(build_sound, 1.0, -5.0)
	hovering_build = -1
	node.add_to_group("buildings")
	node.building_enabled = true
	node = null
	emit_signal("building_placed")
	emit_signal("build_state", false)


func follow_mouse() -> void:
	if !is_instance_valid(node):
		hovering_build = -1
		node = null
		return
		
	var pos = get_viewport().get_mouse_position()
	node.global_position = pos
	
	# Indicate if it's too close to the core
	var dist = pos - GameState.core_position
	if dist.length() < CORE_BUFFER:
		node.modulate = DISABLED_COLOR
	else:
		node.modulate = Color.white


func _input(event: InputEvent) -> void:
	if hovering_build == -1:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			# Include some debounce logic, so we don't prematurely drop the
			# building upon the first release.
			#
			# We must first see the mouse button released, before then 
			# we're allowed to place the building
			if !event.pressed && drop_press_debounce:
				end_build()
				get_tree().set_input_as_handled()
				drop_press_debounce = false
			if event.pressed:
				drop_press_debounce = true


func _process(delta: float) -> void:
	if hovering_build == -1:
		return
		
	follow_mouse()
