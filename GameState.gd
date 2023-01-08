extends Node

const DAY_LENGTH = 30
const NIGHT_LENGTH = 15

var cycles := 0
var night_mode := false

var core: Node2D
var core_position := Vector2.ZERO
var core_power := 5.0
var total_collected_power := 5

var last_switch_time := 0 
var next_switch_time := 0

var game_running = false

var pickup_pitch = 1.0
var attack_pitch = 1.0

signal resource_update
signal mode_update
signal game_win
signal game_active_update
signal game_over

func start() -> void:
	ResourceSpawner.populate_lights_to_ideal()
	
	# Start off during the day
	var time = Time.get_unix_time_from_system()
	next_switch_time = time + DAY_LENGTH
	last_switch_time = time
	game_running = true
	emit_signal("mode_update", night_mode)
	emit_signal("game_active_update", game_running)


func restart() -> void:
	cycles = -1
	
	total_collected_power = 5
	core_power = 5
	core.reset()
	
	clear_enemies()
	clear_resources()
	clear_buildings()

	night_mode = false
	var time = Time.get_unix_time_from_system()
	last_switch_time = time
	begin_day_mode()
	game_running = true
	emit_signal("mode_update", night_mode)
	emit_signal("game_active_update", game_running)
	signal_resource_update()


func win_game() -> void:
	game_running = false
	emit_signal("game_win")
	emit_signal("game_active_update", game_running)
	
	yield(get_tree().create_timer(2.0), "timeout")
	clear_buildings()
	clear_enemies()
	clear_resources()


func end_game() -> void:
	game_running = false
	emit_signal("game_over")
	emit_signal("game_active_update", game_running)


func clear_enemies() -> void:
	var nodes = get_tree().get_nodes_in_group("enemies")
	for node in nodes:
		node.queue_free()


func clear_resources() -> void:
	var nodes = get_tree().get_nodes_in_group("resources")
	for node in nodes:
		var tween = create_tween()
		tween.tween_property(node, "scale", Vector2.ZERO, 0.2)
		tween.tween_callback(node, "queue_free")


func clear_buildings() -> void:
	var nodes = get_tree().get_nodes_in_group("buildings")
	for node in nodes:
		node.queue_free()


func add_core_power(power: float) -> void:
	total_collected_power += power
	core_power += power
	core.update_core()
	signal_resource_update()


func decrease_core_power(power: float) -> void:
	core_power -= power
	if core_power <= 0:
		core_power = 0
	core.update_core()
	signal_resource_update()


func signal_resource_update() -> void:
	emit_signal("resource_update", core_power)


func mode_progress() -> float:
	if !GameState.game_running:
		return 0.0
		
	var time = Time.get_unix_time_from_system()
	return (time - last_switch_time) / (next_switch_time - last_switch_time)


func begin_day_mode() -> void:
	next_switch_time = DAY_LENGTH + last_switch_time
	night_mode = false
	cycles += 1
	
	clear_enemies()
	emit_signal("mode_update", night_mode)
	
	# Spawn resources
	ResourceSpawner.populate_lights_to_ideal()


func begin_night_mode() -> void:
	next_switch_time = NIGHT_LENGTH + last_switch_time
	night_mode = true
	
	clear_resources()
	emit_signal("mode_update", night_mode)
	
	# Spawn enemies
	yield(get_tree().create_timer(1.0), "timeout")
	ResourceSpawner.populate_enemies_to_ideal()


func _process(delta: float) -> void:
	if !game_running:
		return
		
	var time = Time.get_unix_time_from_system()
	if time >= next_switch_time:
		last_switch_time = Time.get_unix_time_from_system()
		if night_mode:
			begin_day_mode()
		else:
			begin_night_mode()
