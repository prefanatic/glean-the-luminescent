extends CPUParticles2D


func _ready() -> void:
	yield(get_tree().create_timer(lifetime), "timeout")
	queue_free()
