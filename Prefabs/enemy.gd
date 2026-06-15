extends Node2D

@onready var orb_prefab = preload("res://Prefabs/orb.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.take_damage()


func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	if area is hurtbox:
		var orb = orb_prefab.instantiate()
		orb.position = position
		get_parent().add_child(orb)
		Event_Bus.enemy_killed.emit(5)
		queue_free()
