extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:	
	player.Jump()
	if player.animation_player and player.animation_player.has_animation("jump_start"):
		player.animation_player.play("jump_start")

func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * delta

	if player.velocity.y < 0:
		if player.animation_player and player.animation_player.has_animation("jump_rise"):
			player.animation_player.play("jump_rise")

	var direction := Input.get_axis("Left", "Right")
	if direction != 0:
		player.velocity.x = move_toward(player.velocity.x, direction * player.SPEED, player.air_accel * delta)
		player.get_node("Sprite2D").flip_h = (direction < 0)
		player.get_node("Marker2D").scale.x = -1 if direction < 0 else 1
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.air_accel * delta)
	
	if not Input.is_action_pressed("Jump") and player.is_jumping:
		player.Jump_cut()
	
	player.move_and_slide()

	# Switch to Falling state once character starts downward trajectory
	if player.velocity.y >= 0:
		finished.emit("Fall")

	if Input.is_action_just_pressed("Attack"):
		finished.emit("Attack")
		return
