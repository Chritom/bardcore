extends PlayerState
class_name PlayerMoveIdle

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity = Vector3.ZERO
	# play idle animation

func physics_update(_delta: float) -> void:
	#player.velocity.y += player.gravity * _delta
	player.velocity.x = move_toward(player.velocity.x, 0, player.stat_comp.get_stat(stat_component.stat_id.MOVEMENT_SPEED))
	player.velocity.z = move_toward(player.velocity.z, 0, player.stat_comp.get_stat(stat_component.stat_id.MOVEMENT_SPEED))
	
	var input_dir = input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir:
		finished.emit(RUNNING)
