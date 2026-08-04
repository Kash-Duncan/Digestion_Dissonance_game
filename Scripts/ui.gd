extends CanvasLayer

var score = 0
var charge_time = 0
var core = 0
@onready var time = $digestion_timer.time_left

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Event_Bus.enemy_killed.connect(add_score)
	Event_Bus.orb_digested.connect(add_score)
	Event_Bus.core_destroyed.connect(add_core)

func add_core(added_core):
	core += added_core
	update_ui()

func add_score(added_score):
	score += added_score
	update_ui()

func update_ui():
	$Label.text = "Score: " + str(score)
	Event_Bus.cores_destoyed = core

func _process(delta: float) -> void:
	time -= delta
	charge_time = Event_Bus._charge_time
	$Digestion_Timer.text = "Time: %.2f " %time
	$Charge_time.text = "Charge: %.2f " %charge_time
