extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:
	if Input.is_action_pressed("Jump"):
		player.is_charging = true

func physics_update(delta: float) -> void:
	if player.is_charging:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
		player.charge_time = min(player.charge_time + delta, player.MAX_charge_time)
		
		var charge_direction := Input.get_axis("Left","Right")
		if charge_direction != 0:
			player.get_node("Sprite2D").flip_h = (charge_direction < 0)
			player.get_node("Marker2D").scale.x = -1 if charge_direction < 0 else 1
			
		# When jump is released, blast off!
		if Input.is_action_just_released("Jump"):
			if player.charge_time >= 0.3:
				player.start_dash()
			else:
				# Charged too short, just do a normal jump instead
				player.is_charging = false
				player.charge_time = 0.0
				player.velocity.y = player.JUMP_VELOCITY
				player.is_jumping = true
				player.Stand()
				finished.emit("Jump")
		return

	# If we are actively moving in the dash
	if player.is_dashing:
		player.execute_dash(delta)
		if not player.is_dashing:
			finished.emit("Idle" if player.is_on_floor() else "Fall")
