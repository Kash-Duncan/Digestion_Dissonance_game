extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:
	player.get_node("Sprite2D").texture = player.stand_texture

func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * delta
	if not player.is_on_floor():
		finished.emit("Fall")
		return

	var direction := Input.get_axis("Left", "Right")
	
	# If no direction is pressed, go back to Idle
	if direction == 0:
		finished.emit("Idle")
		return

	# Movement logic taken from your script
	player.velocity.x = move_toward(player.velocity.x, direction * player.SPEED, player.ground_accel * delta)
	
	# Flip sprite sheets based on vector direction
	player.get_node("Sprite2D").flip_h = (direction < 0)
	player.get_node("Marker2D").scale.x = -1 if direction < 0 else 1
	
	player.move_and_slide()

	# Mid-walk actions
	if Input.is_action_just_pressed("Jump") and player.can_jump:
		if player.Disable_Jump_Timer.is_stopped() and player.jump_timer.is_stopped():
			finished.emit("Jump")
			return
			
	if Input.is_action_just_pressed("Crouch"):
		finished.emit("Crouch")
		return

	if Input.is_action_just_pressed("Attack"):
		finished.emit("Attack")
