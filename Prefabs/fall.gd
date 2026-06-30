extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	# Ensure the player isn't flagged as jumping anymore
	player.is_jumping = false
	
	# Play your fallback placeholder animation
	if player.animation_player:
		player.animation_player.play("fall")

func physics_update(delta: float) -> void:
	# Apply your player's custom falling gravity multipliers from your original script
	if player.velocity.y > -50:
		player.velocity += player.get_gravity() * 2.5 * delta
	else:
		player.velocity += player.get_gravity() * delta

	# Handle horizontal steering/drift while falling in mid-air
	var direction := Input.get_axis("Left", "Right")
	if direction != 0:
		player.velocity.x = move_toward(player.velocity.x, direction * player.SPEED, player.air_accel * delta)
		
		# Flip the sprite and marker based on where the player is drifting
		player.get_node("Sprite2D").flip_h = (direction < 0)
		player.get_node("Marker2D").scale.x = -1 if direction < 0 else 1
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.air_accel * delta)

	# Execute the movement
	player.move_and_slide()

	# Check for landing transitions
	if player.is_on_floor():
		player.can_jump = true # Reset jump capability on landing
		
		# Decide whether to transition to Walk or Idle based on current input
		if Input.get_axis("Left", "Right") != 0:
			finished.emit("Walk")
		else:
			finished.emit("Idle")
