extends PlayerState
class_name PlayerRunning

func enter(previous_state_path: String, data := {}) -> void:
	#play running animation here
	pass

func physics_update(delta: float) -> void:
	var input_dir = input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir:
		player.velocity.x = input_dir.x * player.stat_comp.get_stat(stat_component.stat_id.MOVEMENT_SPEED)
		player.velocity.z = input_dir.y * player.stat_comp.get_stat(stat_component.stat_id.MOVEMENT_SPEED)
	else:
		finished.emit(IDLE)
	
	if input.is_action_just_pressed("jump"):
		finished.emit(DASHING)
