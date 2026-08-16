extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:
	player.attack()
	if player.animation_player and player.animation_player.has_animation("attack"):
		player.animation_player.play("attack")
	if player.coyote_timer:
		player.coyote_timer.stop()
	if not player.is_on_floor():
		player.can_jump = false

func physics_update(delta: float) -> void:
	var direction := Input.get_axis("Left", "Right")
	var target_speed = direction * (player.SPEED)
	if player.is_on_floor():
		
		player.velocity.x = move_toward(player.velocity.x, target_speed, player.ground_accel * delta)
	else:
		player.velocity += player.get_gravity() * delta
		if direction != 0:
			player.velocity.x = move_toward(player.velocity.x, direction * player.SPEED ,player.air_accel * delta)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0 ,player.air_accel * delta)
	
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	else:
		player.can_jump = true
		
	if direction < 0:
		player.get_node("Sprite2D").flip_h = true
		player.get_node("Marker2D").scale.x = -1
	if direction > 0:
		player.get_node("Sprite2D").flip_h = false
		player.get_node("Marker2D").scale.x = 1
	
	player.move_and_slide()
	
	# Return to movement once your attack timer turns the hitbox back off
	if player.hurtbox_collision.disabled:
		if player.is_jumping:
			finished.emit("Fall")
		elif player.is_crouching:
			finished.emit("Crouch")
		elif direction != 0 and player.is_on_floor():
			finished.emit("Walk")
		else:
			finished.emit("Idle")
