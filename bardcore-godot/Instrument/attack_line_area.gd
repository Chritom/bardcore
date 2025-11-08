extends Node3D
var beatTimer: Timer
@export var attack_sound: AudioStreamPlayer3D

func _ready() -> void:
	beatTimer = get_tree().get_first_node_in_group('BeatTimer')
	#unnecessary, it's already connected by hand (check your nodes)
	#attack_sound.finished.connect(clean_up)
	beatTimer.timeout.connect(_on_triggered)

func _on_triggered() -> void:
	print("EXPLOSION!")
	attack_sound.play()
	beatTimer.timeout.disconnect(_on_triggered)

func clean_up() -> void:
	print("clean up")
	queue_free()
