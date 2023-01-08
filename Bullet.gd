extends RigidBody2D

const SPEED = 400

var direction := Vector2.ZERO
var velocity := Vector2.ZERO

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(node: Node2D) -> void:
	if node is Enemy:
		node.destroy()
		queue_free()


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	state.linear_velocity = direction * SPEED 
