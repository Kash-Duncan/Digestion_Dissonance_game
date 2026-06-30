extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:
	player.attack()

func physics_update(delta: float) -> void:
	# Apply normal movement gravity/friction during attack window
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	player.move_and_slide()
	
	# Return to movement once your attack timer turns the hitbox back off
	if player.hurtbox_collision.disabled:
		finished.emit("Idle" if player.is_on_floor() else "Fall")
