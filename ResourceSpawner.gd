extends Node

onready var light_resource := preload("res://LightResource.tscn")
onready var enemy_resource := preload("res://Enemy.tscn")

const LIGHT_SPAWN_RANGE := Rect2(Vector2.ZERO, Vector2(1024, 600))
const CORE_DIST = 200
const ENEMY_CORE_DIST = 400
const IDEAL_POINTS = 15
const ENEMY_SPAWN_RATE = 2.2


func populate_lights_to_ideal() -> void:
	var existing = get_tree().get_nodes_in_group("resources").size()
	var count = IDEAL_POINTS - existing
	count += GameState.cycles # Throw a bone!
	for i in range(0, count):
		spawn_light()


# Returns a spawn point found within rect,
# but tries to avoid placing near the core.
func get_spawn_point(rect: Rect2, core_buffer: int) -> Vector2:
	var position: Vector2
	var iterations = 0
	while true:
		var point_x = rand_range(rect.position.x, rect.size.x)
		var point_y = rand_range(rect.position.y, rect.size.y)
		position = Vector2(point_x, point_y)
		var distance = position - GameState.core_position
		if distance.length() >= core_buffer:
			break
		if iterations >= 100:
			break
	return position


func spawn_light() -> void:
	var res = light_resource.instance()
	res.position = get_spawn_point(LIGHT_SPAWN_RANGE, CORE_DIST)
	get_tree().current_scene.add_child(res)
	res.add_to_group("resources")


func populate_enemies_to_ideal() -> void:
	var existing = get_tree().get_nodes_in_group("enemies").size()
	var ideal = (ENEMY_SPAWN_RATE * GameState.cycles) + 5
	var count = ideal - existing
	for i in range(0, count):
		spawn_enemy()


func spawn_enemy() -> void:
	var res = enemy_resource.instance()
	res.position = get_spawn_point(LIGHT_SPAWN_RANGE, ENEMY_CORE_DIST)
	get_tree().current_scene.add_child(res)
	res.add_to_group("enemies")
