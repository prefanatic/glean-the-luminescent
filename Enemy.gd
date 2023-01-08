extends RigidBody2D
class_name Enemy

const SPEED = 30
const ATTACK_RATE = 2

var target: Node2D
var should_attack = false
var next_attack = 0

onready var hit_sound := preload("res://enemy_attack.wav")
onready var hit_particles := preload("res://BulletHitParticles.tscn")

func _ready() -> void:
	$PunchRange.connect("body_entered", self, "_on_body_entered")
	$PunchRange.connect("body_exited", self, "_on_body_exited")


func _on_body_entered(node: Node2D) -> void:
	if node.name == "CoreBody":
		target = node.get_parent()
		should_attack = true
	if node is Tower || node is Collector:
		should_attack = true
		target = node


func _on_body_exited(node: Node2D) -> void:
	if target == node:
		node = null
		should_attack = false


func destroy() -> void:
	var particles = hit_particles.instance()
	particles.emitting = true
	particles.global_position = global_position
	get_tree().root.add_child(particles)
	queue_free()


func punch() -> void:
	var current_position = position
	var direction = (target.position - position).normalized()
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + direction * 6, 0.1)
	if target.has_method("do_hit"):
		tween.tween_callback(target, "do_hit")
	tween.tween_callback(AudioService, "play", [hit_sound, 1.0, -10.857])
	tween.tween_property(self, "position", current_position, 0.1)


func _process(delta: float) -> void:
	if should_attack && Time.get_unix_time_from_system() >= next_attack:
		next_attack = Time.get_unix_time_from_system() + ATTACK_RATE + rand_range(0.0, 2.0)
		punch()


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if GameState.night_mode:
		var speed_offset = GameState.cycles * 4
		
		# Always move toward core
		var distance = GameState.core_position - position
		var velocity = distance.normalized() * (SPEED + speed_offset)

		# Only move with no target
		if (!is_instance_valid(target)):
			state.linear_velocity = velocity
		else:
			state.linear_velocity = Vector2.ZERO
