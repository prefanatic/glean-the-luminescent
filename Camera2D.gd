extends Camera2D

var shake := false

func _ready() -> void:
	GameState.connect("game_win", self, "_on_game_win")


func _on_game_win() -> void:
	shake = true
	yield(get_tree().create_timer(2.5), "timeout")
	shake = false


func _process(delta: float) -> void:
	if !shake:
		return
	offset = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
