extends CharacterBody2D

@onready var orb_prefab = preload("res://Prefabs/orb.tscn")
@onready var enemy_hitbox = $Marker2D/Hurtbox
@onready var health_bar = $health_bar
var health : int = 30
const SPEED = 200
const JUMP_VELOCITY = -300.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: CharacterBody2D = $"../player"
@onready var animation_player = $AnimationPlayer


func _ready() -> void:
	set_health()
	animation_player.play("Idle")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not player:
		return
	
	nav_agent.target_position = player.global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	if not nav_agent.is_navigation_finished():
		var dir_x: float = sign(next_path_position.x - global_position.x)
		
		velocity.x = dir_x * SPEED
		if is_on_floor():
			var height_difference: float = global_position.y - next_path_position.y
			if height_difference > 16:
				velocity.y = JUMP_VELOCITY
			elif is_on_wall() and height_difference >= 0:
				velocity.y = JUMP_VELOCITY
		
		if dir_x != 0:
			$Sprite2D.flip_h = (dir_x < 0)
			$Marker2D.scale.x = -1 if dir_x < 0 else 1
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var current_agent_postion: Vector2 = global_position
	
	move_and_slide()
	
	if abs(velocity.x) > 10:
		if abs(velocity.x) > 100:
			animation_player.play("Run")
		else:
			animation_player.play("Walk")
	else:
		animation_player.play("Idle")

func set_health():
	health_bar.max_value = health
	health_bar.value = health
	
func update_health(Amount: int):
	health += Amount
	health_bar.value = health
	
	if health <= 0:
		queue_free()

func enemy_killed():
	var orb = orb_prefab.instantiate()
	orb.position = position
	get_parent().add_child(orb)
	Event_Bus.enemy_killed.emit(5)
	queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.update_health(-10)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox":
		update_health(-10)
