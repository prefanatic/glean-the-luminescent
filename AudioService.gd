extends Node

var number_of_players := 10

var index := 0
var _players := Array()

func _ready() -> void:
	for i in range(0, number_of_players):
		var player = AudioStreamPlayer.new()
		_players.append(player)
		add_child(player)

func get_player() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = _players[index]
	index = (index + 1 ) % number_of_players
	return player


func play(stream: AudioStream, pitch: float, volume: float) -> void:
	var player = get_player()
	player.stream = stream
	player.volume_db = volume
	player.pitch_scale = pitch
	player.play()
