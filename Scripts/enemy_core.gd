extends CharacterBody2D

@onready var enemy_hitbox = $Marker2D/Hitbox
@onready var health_bar = $health_bar
var health : int = 30


func _ready() -> void:
	set_health()

func set_health():
	health_bar.max_value = health
	health_bar.value = health
	
func update_health(Amount: int):
	health += Amount
	health_bar.value = health
	
	if health <= 0:
		destroy_core()

func destroy_core():
	Event_Bus.core_destroyed.emit(1)
	queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.update_health(-10)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox":
		update_health(-10)
