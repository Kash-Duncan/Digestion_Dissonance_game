extends Node2D

@onready var digestion_timer = $digestion_timer


func _on_digestion_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")
