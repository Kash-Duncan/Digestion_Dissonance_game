extends PlayerState

func enter(_previous_state_path: String, data := {}) -> void:
	player.digest()
	player.animation_player.play("digest")

func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * delta
	var direction := Input.get_axis("Left", "Right")
	var target_speed = direction * (player.SPEED)
	player.velocity.x = move_toward(player.velocity.x, target_speed, player.ground_accel * delta)
	
	player.get_node("Sprite2D").flip_h = (direction < 0)
	player.get_node("Marker2D").scale.x = -1 if direction < 0 else 1
	
	player.move_and_slide()
	if player.pickup_collision.disabled:
		finished.emit("Idle")
	
