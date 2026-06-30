extends Node
class_name State

signal finished(target_state_path: String, data: Dictionary)


func handle_input(_event: InputEvent) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass
