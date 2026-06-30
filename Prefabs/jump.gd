extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:
	player.Jump()
	if player.jump_timer.is_stopped():
		player.jump_timer.start()

func physics_update(delta: float) -> void:
	# Add standard jumping gravity
	player.velocity += player.get_gravity() * delta

	# Mid-air horizontal drifting control
	var direction := Input.get_axis("Left", "Right")
	if direction != 0:
		player.velocity.x = move_toward(player.velocity.x, direction * player.SPEED, player.air_accel * delta)
		player.get_node("Sprite2D").flip_h = (direction < 0)
		player.get_node("Marker2D").scale.x = -1 if direction < 0 else 1
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.air_accel * delta)

	player.move_and_slide()

	# Handle variable jump height cuts when releasing the key
	if Input.is_action_just_released("Jump") and player.is_jumping:
		player.Jump_cut()

	# Switch to Falling state once character starts downward trajectory
	if player.velocity.y >= 0:
		finished.emit("Fall")
