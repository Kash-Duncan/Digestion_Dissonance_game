extends PlayerState

@export var crouch_speed_multiplyer := 0.80

func enter(_previous_state_path: String, data := {}) -> void:
	player.Crouch()
	if player.animation_player and player.animation_player.has_animation("crouch_idle"):
		player.animation_player.play("crouch_idle")

func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * delta
	var direction := Input.get_axis("Left", "Right")
	var target_speed = direction * (player.SPEED * crouch_speed_multiplyer)
	player.velocity.x = move_toward(player.velocity.x, target_speed, player.ground_accel * delta)
	player.move_and_slide()
	
	if direction != 0:
		player.get_node("Sprite2D").flip_h = (direction < 0)
		player.get_node("Marker2D").scale.x = -1 if direction < 0 else 1
		player.animation_player.play("crouch_walk")
	else:
		player.animation_player.play("crouch_idle")
	
	if Input.is_action_pressed("Jump"):
		finished.emit("Dash")
		return
	
	if Input.is_action_just_pressed("Stand") and not player.crouch_checker.is_colliding():
		player.Stand()
		finished.emit("Idle")
	
	if Input.is_action_pressed("Digest"):
		finished.emit("Digest")
		return
	
	if Input.is_action_just_pressed("Attack"):
		finished.emit("Attack")
		return
