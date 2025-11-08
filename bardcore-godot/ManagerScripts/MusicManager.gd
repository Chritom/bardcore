extends Node

var music_player: AudioStreamPlayer
var music_list = []
var current_music

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_music = 0
	play_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_music(index) -> void:
	current_music = index
	play_music()

func play_music() -> void:
	music_player.set_stream(music_list[current_music])
