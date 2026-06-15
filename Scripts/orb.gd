extends Area2D

#if player presses "shift" orb will be picked up


func _on_area_entered(area: Area2D) -> void:
	if area is pickup_box:
		Event_Bus.orb_digested.emit(1)
		queue_free()
