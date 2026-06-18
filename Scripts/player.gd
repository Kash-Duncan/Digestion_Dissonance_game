extends CharacterBody2D

class_name player

@onready var stand_texture = preload("res://Textures/Player-4.png.png")
@onready var crouch_texture = preload("res://Textures/Player_Crouch.png")
@onready var jump_timer = $jump_timer
@onready var Stand_shape = $Standing_Shape
@onready var Crouch_shape = $Crouch_Shape
@onready var Disable_Jump_Timer = $Disable_Jump_Timer
@onready var Gravity_cancel_timer = $Gravity_Cancel_timer
@onready var crouch_checker = $Crouch_ShapeCast2D
@onready var hurtbox_collision = $Marker2D/hurtbox/hurtbox_collision
@onready var pickup_collision = $pickup_box/CollisionShape2D
@onready var attack_timer = $attack_timer
@onready var pickup_timer = $pickup_timer
@onready var health_bar = $health_bar
@export var health : int = 100

func _ready() -> void:
	set_health()

const orignal_speed = 300.0
var SPEED = 300.0
const JUMP_VELOCITY = -350.0
const DASH_SPEED = 950
const MAX_charge_time = 1.0
const DASH_duration = 0.35
const ground_accel = 4000.0
const air_accel = 1500.0

var DASH_HEIGHT = randi_range(-250,-300)
var is_charging := false
var charge_time := 0.0
var is_dashing := false
var dash_timer := 0.0
var dash_dir := Vector2.ZERO

var can_jump = true
var is_crouching = false

var start_position = Vector2(-607.0,-38.0)

func Jump():
	if is_crouching == false:
		velocity.y = JUMP_VELOCITY
	elif not Input.is_action_pressed("Crouch") and not crouch_checker.is_colliding():
		Disable_Jump_Timer.start()
		Stand_shape.disabled = false
		is_crouching = false
		Crouch_shape.disabled = true

func Jump_cut():
	if velocity.y < -150 and velocity.y > -50:
		velocity.y = 250
		can_jump = false
		jump_timer.stop()

func Crouch():
	if is_on_floor():
		if is_crouching:
			return
		is_crouching = true
		Stand_shape.disabled = true
		Crouch_shape.disabled = false

func Stand():
	if is_crouching == false:
		return
	is_crouching = false
	Crouch_shape.disabled = true
	Stand_shape.disabled = false
	
func attack():
	var input_d = Input.get_axis("ui_left","ui_right")
	attack_timer.start()
	if input_d != 0:
		hurtbox_collision.disabled = false
	else:
		hurtbox_collision.disabled = false

func digest():
	pickup_timer.start()
	pickup_collision.disabled = false

func _on_jump_timer_timeout() -> void:
	can_jump = false
	Jump_cut()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > -50:
			velocity += get_gravity() * 2.5 * delta
		else:
			velocity += get_gravity() * delta

	if is_dashing:
		execute_dash(delta)
		return
	#charging the dash
	if is_on_floor() and Input.is_action_pressed("ui_down") and Input.is_action_pressed("Jump"):
		is_charging = true
		velocity.x = move_toward(velocity.x, 0, SPEED)
		charge_time = min(charge_time + delta, MAX_charge_time)
	else: #Released/normal movement
		if is_charging:
			if charge_time >= 0.3:
				start_dash()
				return
			else:
				is_charging = false
				charge_time = 0.0
				velocity.y = JUMP_VELOCITY
				#ADD Stand feature when dash timer isnt accepted
		if not is_charging and not is_dashing:
			var direction := Input.get_axis("ui_left", "ui_right")
			
			var current_accel: float
			if is_on_floor():
				current_accel = ground_accel
			else:
				current_accel = air_accel
			if direction:
				velocity.x = move_toward(velocity.x, direction * SPEED, current_accel * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, current_accel * delta)
			if velocity.x > 0:
				$Sprite2D.flip_h = false
				$Marker2D.scale.x = 1
			elif velocity.x < 0:
				$Sprite2D.flip_h = true
				$Marker2D.scale.x = -1
			if is_crouching:
				$Sprite2D.texture = crouch_texture
			else:
				$Sprite2D.texture = stand_texture
			# Handle jump.
			if Input.is_action_pressed("Jump") and can_jump == true:
				if Disable_Jump_Timer.is_stopped():
					if jump_timer.is_stopped():
						jump_timer.start()
					Jump()
			#Handle Jump Cut
			if Input.is_action_just_released("Jump"):
				Jump_cut()

	if is_on_floor():
		can_jump = true
	
	if Input.is_action_pressed("Crouch"):
		Crouch()
	
	if Input.is_action_just_pressed("Stand") and not crouch_checker.is_colliding():
		Stand()
	
	if Input.is_action_just_pressed("Attack"):
		attack()
	
	if Input.is_action_pressed("Digest"):
		digest()
	
	move_and_slide()

func start_dash():
	is_charging = false
	is_dashing = true
	dash_timer = DASH_duration
	var input_d = Input.get_axis("ui_left","ui_right")
	if input_d != 0:
		dash_dir = Vector2(input_d, 0).normalized()
	else:
		#RIGHT means default dashing will be right
		dash_dir = Vector2.UP
	
	var charge_percent = charge_time / MAX_charge_time
	var final_force = DASH_SPEED * lerp(0.5, 1.0, charge_percent)
	
	velocity.x = dash_dir.x * final_force
	velocity.y = -400.0
	charge_time = 0.0
	
func execute_dash(delta: float):
	dash_timer -= delta
	var air_steer = Input.get_axis("ui_left","ui_right")
	if air_steer != 0:
		velocity.x = move_toward(velocity.x, air_steer * DASH_SPEED, SPEED * delta)
	velocity += get_gravity() * delta
	
	if dash_timer <= 0:
		is_dashing = false
		velocity.x = move_toward(velocity.x, 0, SPEED * 70 * delta)
	move_and_slide()


func end_screen():
	get_tree().change_scene_to_file("res://Scenes/win_scene.tscn")

func _on_gravity_cancel_timer_timeout() -> void:
	SPEED = orignal_speed

func _on_attack_timer_timeout() -> void:
	hurtbox_collision.disabled = true

func _on_pickup_timer_timeout() -> void:
	pickup_collision.disabled = true

func set_health():
	health_bar.max_value = health
	health_bar.value = health

func update_health(Amount: int):
	health += Amount
	health_bar.value = health

func _process(delta: float) -> void:
	if health == 0:
		get_tree().change_scene_to_file("res://Scenes/lose_scene.tscn")
	Event_Bus._charge_time = charge_time
