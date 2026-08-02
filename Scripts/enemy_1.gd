extends CharacterBody2D

@onready var enemy_hitbox = $Marker2D/Hitbox
@onready var health_bar = $health_bar
var health : int = 30
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var player: CharacterBody2D = player_node


func _ready() -> void:
	set_health()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player:
		nav_agent.target_position = player.global_position
	if nav_agent.is_navigation_finished():
		return

	move_and_slide()

func set_health():
	health_bar.max_value = health
	health_bar.value = health
	
func update_health(Amount: int):
	health += Amount
	health_bar.value = health
	
	if health <= 0:
		queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.update_health(-10)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox":
		update_health(-10)
