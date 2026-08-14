extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	player.animation_player.play("idle")

func physics_update(delta: float) -> void:
	# Fall if we suddenly lose the floor beneath us
	if not player.is_on_floor():
		finished.emit("Fall")
		return

	# Transition to Walk if moving
	var direction := Input.get_axis("Left", "Right")
	if direction != 0:
		finished.emit("Walk")
		return

	# Handle Actions from Idle
	if Input.is_action_just_pressed("Crouch"):
		finished.emit("Crouch")
		return
		
	if Input.is_action_pressed("Jump") and player.can_jump:
		if player.Disable_Jump_Timer.is_stopped() and player.jump_timer.is_stopped():
			finished.emit("Jump")
			return

	if Input.is_action_just_pressed("Attack"):
		finished.emit("Attack")
		return

	if Input.is_action_pressed("Digest"):
		finished.emit("Digest")
		return

	# Apply friction/stop movement and apply gravity just in case
	player.velocity.x = move_toward(player.velocity.x, 0, player.ground_accel * delta)
	player.move_and_slide()
