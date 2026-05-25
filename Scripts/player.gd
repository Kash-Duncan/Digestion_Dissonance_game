extends CharacterBody2D

@onready var jump_timer = $jump_timer

const SPEED = 250.0
const JUMP_VELOCITY = -350.0

var can_jump = true
var is_crouching = false

func _process(delta: float) -> void:
	print(is_crouching)

func Jump():
	velocity.y = JUMP_VELOCITY
 
func Jump_cut():
	if velocity.y < 150:
		velocity.y = 150
		can_jump = false
		jump_timer.stop()

func Crouch():
	if is_crouching:
		return
	is_crouching = true

func Stand():
	if is_crouching == false:
		return
	is_crouching == false

func _on_jump_timer_timeout() -> void:
	can_jump = false
	Jump_cut()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("Jump") and can_jump == true:
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
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if is_on_floor():
		can_jump = true
	
	if Input.is_action_just_pressed("Crouch"):
		Crouch()
	#Standing doesnt work
	if Input.is_action_just_pressed("Stand"):
		Stand()
		
	move_and_slide()
