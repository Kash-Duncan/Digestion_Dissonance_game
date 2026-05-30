extends CharacterBody2D

@onready var jump_timer = $jump_timer
@onready var Stand_shape = $Standing_Shape
@onready var Crouch_shape = $Crouch_Shape
@onready var Disable_Jump_Timer = $Disable_Jump_Timer
@onready var Gravity_cancel_timer = $Gravity_Cancel_timer

const orignal_speed = 250.0
var SPEED = 250.0
const JUMP_VELOCITY = -350.0
const DASH_SPEED = 800
const MAX_charge_time = 1.0
const DASH_duration = 0.2
const ground_accel = 1800.0
const air_accel = 700.0

var DASH_HEIGHT = randi_range(-250,-300)
var is_charging := false
var charge_time := 0.0
var is_dashing := false
var dash_timer := 0.0
var dash_dir := Vector2.ZERO

var can_jump = true
var is_crouching = false

func _process(delta: float) -> void:
	pass


func Jump():
	if is_crouching == false:
		velocity.y = JUMP_VELOCITY
	elif not Input.is_action_pressed("Crouch"):
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
	
	if Input.is_action_just_pressed("Stand"):
		Stand()
	
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
		dash_dir = Vector2.RIGHT
	
	var charge_percent = charge_time / MAX_charge_time
	var final_force = DASH_SPEED * lerp(0.5, 1.0, charge_percent)
	
	velocity.x = dash_dir.x * final_force
	velocity.y = -220.0
	charge_time = 0.0
	
func execute_dash(delta: float):
	dash_timer -= delta
	var air_steer = Input.get_axis("ui_left","ui_right")
	if air_steer != 0:
		velocity.x = move_toward(velocity.x, air_steer * DASH_SPEED, SPEED * delta)
	velocity += get_gravity() * delta
	
	if dash_timer <= 0:
		is_dashing = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()


func _on_gravity_cancel_timer_timeout() -> void:
	SPEED = orignal_speed
