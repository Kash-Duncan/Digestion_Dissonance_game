extends PlayerState

@export var crouch_speed_multiplyer := 0.80

func enter(_previous_state_path: String, data := {}) -> void:
	player.Crouch()
	_play_crouch_animation("crouch_idle")

func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * delta
	var direction := Input.get_axis("Left", "Right")
	var target_speed = direction * (player.SPEED * crouch_speed_multiplyer)
	player.velocity.x = move_toward(player.velocity.x, target_speed, player.ground_accel * delta)
	player.move_and_slide()
	
	if direction != 0:
		player.get_node("Sprite2D").flip_h = (direction < 0)
		player.get_node("Marker2D").scale.x = -1 if direction < 0 else 1
		_play_crouch_animation("crouch_walk")
	else:
		_play_crouch_animation("crouch_idle")
	
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

func _play_crouch_animation(anim_name: String) -> void:
	if player.animation_player and player.animation_player.has_animation(anim_name):
		if player.animation_player.current_animation != anim_name:
			player.animation_player.play(anim_name)
