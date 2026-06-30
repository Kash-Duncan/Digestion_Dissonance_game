extends State

class_name PlayerState

const IDLE = "Idle"
const WALKING = "Walk"
const CROUCHING = "Crouching"
const STANDING = "Standing"
const JUMPING = "Jumping"
const DASHING = "Dashing"
const ATTACKING = "Attacking"
const FALLING = "Falling"
const DIGESTING = "Digesting"
const ATTRIBUTE = "Attribute"

var player: Player


func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
