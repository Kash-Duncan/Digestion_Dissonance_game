extends CanvasLayer

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Event_Bus.enemy_killed.connect(add_score)
	
func add_score(added_score):
	score += added_score
	update_ui()

func update_ui():
	$Label.text = "Score: " + str(score)
