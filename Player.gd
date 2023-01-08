extends KinematicBody2D
class_name Player

const MIN_SPEED = 100
const MAX_SPEED = 175
const SPEED_RATE = 1.0
const ATTACK_COST = 0.5
const ATTACK_COOLDOWN = 0.5

var speed = 0
var velocity := Vector2.ZERO
var light := 0

var next_attack = 0

var pickup_pitch = 1.0

onready var shoot_sound := preload("res://shoot.wav")
onready var pickup_sound := preload("res://pickup.wav")
onready var bullet := preload("res://Bullet.tscn")
onready var sprite := $Sprite

func _ready() -> void:
	var points = PoolVector2Array()
	points.append(Vector2.ZERO)
	points.append(Vector2.ZERO)
	$Line2D.points = points
	
	GameState.connect("game_active_update", self, "_on_game_state_update")
	GameState.connect("mode_update", self, "_on_mode_update")
	scale = Vector2.ZERO


func _on_game_state_update(running: bool) -> void:
	var next_scale: Vector2
	if running:
		next_scale = Vector2.ONE
	else:
		next_scale = Vector2.ZERO
		
	var tween = create_tween()
	tween.tween_property(self, "scale", next_scale, 0.2)


func _on_mode_update(night_mode: bool) -> void:
	$Line2D.visible = night_mode


func light_count() -> int:
	var count = 0
	for node in get_children():
		if node is LightResource:
			count += 1
	return count


func pickup_light() -> void:
	pickup_pitch = 1.0 + (light_count() / 10.0)
	AudioService.play(pickup_sound, pickup_pitch, 0.0)


func dropoff_light() -> void:
	pickup_pitch = 1.0 + (light_count() / 10.0)
	AudioService.play(pickup_sound, pickup_pitch, 0.0)


func attack() -> void:
	if !GameState.night_mode:
		return

	var time = Time.get_unix_time_from_system()
	if time >= next_attack:
		next_attack = time + ATTACK_COOLDOWN
		GameState.decrease_core_power(ATTACK_COST)
		AudioService.play(shoot_sound, 1.0, -10.0)
		
		var mouse_pos = get_viewport().get_mouse_position()
		var direction = (mouse_pos - global_position).normalized()
		var node = bullet.instance()
		
		node.global_position = global_position + (direction * 2)
		node.direction = direction
		get_tree().root.add_child(node)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			attack()


func _process(delta: float) -> void:
	if !GameState.night_mode:
		return
		
	var mouse_pos = get_viewport().get_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	$Line2D.set_point_position(0, Vector2.ZERO)
	$Line2D.set_point_position(1, direction * 40)


func _physics_process(delta: float) -> void:
	if !GameState.game_running:
		return
		
	var horizontal := Input.get_axis("move_left", "move_right")
	var vertical := Input.get_axis("move_up", "move_down")
	
	if (horizontal || vertical):
		speed = clamp(speed + SPEED_RATE, MIN_SPEED, MAX_SPEED)
		
		velocity.x = horizontal
		velocity.y = vertical
		velocity = velocity.normalized() * speed
	else:
		speed = MIN_SPEED
		velocity.x = move_toward(velocity.x, 0, MIN_SPEED)
		velocity.y = move_toward(velocity.y, 0, MIN_SPEED)
		
	move_and_slide(velocity)
	global_position.x = clamp(global_position.x, 0, 1024)
	global_position.y = clamp(global_position.y, 0, 600)
