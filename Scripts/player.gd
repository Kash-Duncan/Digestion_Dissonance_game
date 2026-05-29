extends CharacterBody2D

@onready var jump_timer = $jump_timer
@onready var Stand_shape = $Standing_Shape
@onready var Crouch_shape = $Crouch_Shape
@onready var Disable_Jump_Timer = $Disable_Jump_Timer
@onready var Gravity_cancel_timer = $Gravity_Cancel_timer

const orignal_speed = 250.0
var SPEED = 250.0
const JUMP_VELOCITY = -350.0
const DASH_SPEED = 3.5
const DASH_HEIGHT = -250
var test = randi_range(-250,-300)

var can_jump = true
var is_crouching = false

func _process(delta: float) -> void:
	pass
#Get dirction
func Dash():
	var direction_1 := Input.get_axis("ui_left", "ui_right")
	if Input.is_action_pressed("Crouch"):
		Gravity_cancel_timer.start()
		SPEED *= DASH_SPEED
		velocity.y = test
	
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

	# Handle jump.
	if Input.is_action_pressed("Jump") and can_jump == true:
		if Disable_Jump_Timer.is_stopped():
			if jump_timer.is_stopped():
				jump_timer.start()
			Jump()
	#Handle Jump Cut
	if Input.is_action_just_released("Jump"):
		Jump_cut()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	#when moving it cancels this
	elif not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 10)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if is_on_floor():
		can_jump = true
	
	if Input.is_action_pressed("Crouch"):
		Crouch()
	
	if Input.is_action_just_pressed("Stand"):
		Stand()
	#Dash doesnt work uses space
	if Input.is_action_just_pressed("Jump") and Gravity_cancel_timer.is_stopped() and is_on_floor():
		Dash()
	
	move_and_slide()


func _on_gravity_cancel_timer_timeout() -> void:
	SPEED = orignal_speed
