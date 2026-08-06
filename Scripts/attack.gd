extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:
	player.attack()

func physics_update(delta: float) -> void:
	var direction := Input.get_axis("Left", "Right")
	var target_speed = direction * (player.SPEED)
	player.velocity.x = move_toward(player.velocity.x, target_speed, player.ground_accel * delta)
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		
	player.get_node("Sprite2D").flip_h = (direction < 0)
	player.get_node("Marker2D").scale.x = -1 if direction < 0 else 1
	
	player.move_and_slide()
	
	# Return to movement once your attack timer turns the hitbox back off
	if player.hurtbox_collision.disabled:
		if player.is_jumping:
			finished.emit("fall")
			return
		elif player.is_crouching:
			finished.emit("Crouch")
			return
		elif direction != 0 and player.is_on_floor():
			finished.emit("Walk")
			return
