extends Area2D
class_name LightResource

const ROTATE_SPEED = 2
const FOLLOW_DISTANCE = 60

var attach_core = false

var target: Node2D

var angle = 0.0
var dist_random := 0.0
var move_random := 0.0
var rotate_speed_rand := 0.0

onready var sprite := $Sprite

func collect_resource() -> void:
	GameState.add_core_power(1)
	queue_free()


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	set_as_toplevel(true)
	dist_random = rand_range(-5.0, 5.0)
	move_random = rand_range(0.0, 0.0)
	rotate_speed_rand = rand_range(-0.5, 0.5)
	
	var final_scale = scale
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", final_scale, 0.5).set_delay(rand_range(0.1, 0.3))


func attach_target(node: Node) -> void:		
	if get_parent():
		get_parent().remove_child(self)
	node.add_child(self)
	owner = node
	target = node


func _on_body_entered(node: Node) -> void:
	if attach_core:
		return
		
	if node.has_method("pickup_light"):
		node.pickup_light()
		attach_target(node)


func _physics_process(delta: float) -> void:
	if attach_core:
		var distance = target.global_position - global_position
		if (distance.length() > 5):
			global_position = lerp(global_position, target.global_position, 0.05)
		else:
			collect_resource()
			
		return
		
	if target:
		var rotate_speed = ROTATE_SPEED + rotate_speed_rand
		
		angle += rotate_speed * delta
		
		var follow_dist = dist_random + FOLLOW_DISTANCE
		var distance = target.global_position - global_position
		if (distance.length() > follow_dist):
			global_position = lerp(global_position, target.global_position, delta + move_random)
			return
		
		var ideal_position = target.global_position + Vector2(sin(angle), cos(angle)) * follow_dist
		global_position = lerp(global_position, ideal_position, delta + move_random)
