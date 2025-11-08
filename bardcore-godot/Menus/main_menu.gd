extends Control



func _on_play_button_pressed() -> void:
	MapManager.load_map()
	queue_free()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
