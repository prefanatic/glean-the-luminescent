extends StaticBody2D
class_name Tower

const ATTACK_COOLDOWN = 1.75
const ATTACK_RANGE = 140

onready var laser_sound := preload("res://laser.wav")

var building_enabled := false
var next_attack := 0
var health := 3

onready var line := $TowerLaser

func do_hit() -> void:
	health -= 1
	
	if health <= 0:
		queue_free()


func _process(delta: float) -> void:
	if !building_enabled:
		return

	attack()


func attack() -> void:
	if !GameState.night_mode:
		return
		
	var time = Time.get_unix_time_from_system()
	if time >= next_attack:
		next_attack = time + ATTACK_COOLDOWN + rand_range(0.0, 0.5)
		
		# Collect nearby nodes, take a random one
		var nodes = collect_nearby_nodes() 
		if nodes.empty():
			return
			
		var index = rand_range(0, nodes.size() - 1)
		var node = nodes[index]
		
		var points = PoolVector2Array()
		points.append(Vector2.ZERO)
		points.append(node.global_position - global_position)
		line.points = points
		
		AudioService.play(laser_sound, 1.0, -18.0)
		var tween = create_tween()
		tween.tween_property(line, "width", 5.0, 0.2)
		tween.tween_callback(node, "destroy")
		tween.tween_property(line, "width", 0.0, 0.6)


func collect_nearby_nodes() -> Array:
	var array = Array()
	var nodes = get_tree().get_nodes_in_group("enemies")
	for node in nodes:
		var distance = global_position - node.global_position
		if (distance.length() < ATTACK_RANGE):
			array.append(node)
	return array
