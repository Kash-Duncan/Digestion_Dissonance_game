extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:
	player.digest()

func physics_update(delta: float) -> void:
	player.move_and_slide()
	if player.pickup_collision.disabled:
		finished.emit("Idle")
