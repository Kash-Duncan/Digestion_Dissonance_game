extends CharacterBody2D
class_name Player

@onready var stand_texture = preload("res://Textures/Characters/Player-4.png.png")
@onready var crouch_texture = preload("res://Textures/Characters/Player_Crouch.png")
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
@onready var animation_player = $animation_player
@onready var min_jump_timer = $min_jump_timer

@export var health : int = 100
const orignal_speed = 300.0
var SPEED = 300.0
var JUMP_VELOCITY = -450.0
const DASH_SPEED = 950
@export var MAX_charge_time = 1.0
const DASH_duration = 0.4
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
var is_jumping = false
var start_position = Vector2(-607.0,-38.0)

func _ready() -> void:
	set_health()
	if animation_player and animation_player.has_animation("idle"):
		animation_player.play("idle")
func _process(delta: float) -> void:
	if health == 0:
		get_tree().change_scene_to_file("res://Scenes/lose_scene.tscn")
	if "Event_Bus" in self:
		Event_Bus._charge_time = charge_time

func Stand():
	is_crouching = false
	Crouch_shape.disabled = true
	Stand_shape.disabled = false

func Jump():
	Stand()
	velocity.y = JUMP_VELOCITY
	is_jumping = true
	if min_jump_timer.is_stopped():
		min_jump_timer.start()
func Jump_cut():
	if not is_jumping:
		return
	if not min_jump_timer.is_stopped():
		return
	is_jumping = false
	jump_timer.stop()
	if velocity.y < 0:
		velocity.y *= 0.5
		can_jump = false
		is_jumping = false

func Crouch():
	if is_on_floor():
		if is_crouching: return
		is_crouching = true
		Stand_shape.disabled = true
		Crouch_shape.disabled = false
	
func attack():
	attack_timer.start()
	hurtbox_collision.disabled = false

func digest():
	pickup_timer.start()
	pickup_collision.disabled = false

func start_dash():
	is_charging = false
	is_dashing = true
	dash_timer = DASH_duration
	var input_d = Input.get_axis("Left","Right")
	if input_d == 0:
		input_d = -1.0 if $Sprite2D.flip_h else 1.0
	dash_dir = Vector2(input_d, 0).normalized()
	
	$Sprite2D.flip_h = (input_d < 0)
	$Marker2D.scale.x = -1 if input_d < 0 else 1
	
	var charge_percent = charge_time / MAX_charge_time
	var final_force = DASH_SPEED * lerp(0.5, 1.0, charge_percent)
	velocity.x = dash_dir.x * final_force
	velocity.y = -300.0
	charge_time = 0.0

func execute_dash(delta: float):
	dash_timer -= delta
	var air_steer = Input.get_axis("Left","Right")
	if air_steer != 0:
		velocity.x = move_toward(velocity.x, air_steer * DASH_SPEED, SPEED * delta)
	velocity += get_gravity() * delta
	if dash_timer <= 0:
		is_dashing = false
		velocity.x = move_toward(velocity.x, 0, SPEED * 70 * delta)
	move_and_slide()

# KEEP: Timer and UI helpers
func _on_jump_timer_timeout() -> void:
	can_jump = false
	Jump_cut()
func _on_gravity_cancel_timer_timeout() -> void: SPEED = orignal_speed
func _on_attack_timer_timeout() -> void: hurtbox_collision.disabled = true
func _on_pickup_timer_timeout() -> void: pickup_collision.disabled = true
func set_health():
	health_bar.max_value = health
	health_bar.value = health
func update_health(Amount: int):
	health += Amount
	health_bar.value = health

func end_screen():
	get_tree().change_scene_to_file("res://Scenes/win_scene.tscn")

func tut_finished():
	get_tree().change_scene_to_file("res://Scenes/cores.tscn")


func _on_finshed_game_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
