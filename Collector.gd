extends StaticBody2D
class_name Collector

const SPAWN_RATE = 6
const MAX_BATCH = 3

onready var resource := preload("res://LightResource.tscn")
var next_spawn := 0

var batched := 0
var building_enabled := false
var health := 3

func do_hit() -> void:
	health -= 1
	
	if health <= 0:
		queue_free()


func _ready() -> void:
	next_spawn = Time.get_unix_time_from_system() + SPAWN_RATE
	GameState.connect("mode_update", self, "_on_mode_update")


func _on_mode_update(night_mode: bool) -> void:
	if !night_mode:
		_spawn()

func _process(delta: float) -> void:
	if !building_enabled:
		return
		
	var time = Time.get_unix_time_from_system()
	if time >= next_spawn:
		next_spawn = time + SPAWN_RATE
		if GameState.night_mode:
			# Twice as slow during night
			next_spawn += (SPAWN_RATE)
		
		if batched < MAX_BATCH:
			batched += 1
		if GameState.night_mode:
			return
		
		_spawn()


func _spawn() -> void:
	while batched > 0:
		var node = resource.instance()
		node.global_position = global_position
		node.attach_target(self)
		node.add_to_group("resources")
		
		batched -= 1
		yield(get_tree().create_timer(0.5), "timeout")
