extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	player.is_jumping = false
	
	if player.animation_player:
		player.animation_player.play("fall")

func physics_update(delta: float) -> void:
	if player.velocity.y > -50:
		player.velocity += player.get_gravity() * 2.5 * delta
	else:
		player.velocity += player.get_gravity() * delta

	if player.is_on_floor():
		if player.animation_player and player.animation_player.has_animation("jump_land"):
			player.animation_player.play("jump_land")
	
	var direction := Input.get_axis("Left", "Right")
	if direction != 0:
		player.velocity.x = move_toward(player.velocity.x, direction * player.SPEED, player.air_accel * delta)
		
		player.get_node("Sprite2D").flip_h = (direction < 0)
		player.get_node("Marker2D").scale.x = -1 if direction < 0 else 1
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.air_accel * delta)
	if Input.is_action_just_released("Jump") and player.velocity.y < 0:
		player.Jump_cut()

	player.move_and_slide()

	if player.is_on_floor():
		player.can_jump = true
		if Input.is_action_pressed("Crouch"):
			finished.emit("Crouch")
			return
		if Input.get_axis("Left", "Right") != 0:
			finished.emit("Walk")
		else:
			finished.emit("Idle")
	
	if Input.is_action_just_pressed("Attack"):
		finished.emit("Attack")
		return
