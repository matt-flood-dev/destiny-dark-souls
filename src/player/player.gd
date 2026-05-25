extends CharacterBody3D
class_name Player

# --- CONFIGURATIONS ---
const DOUBLE_TAP_TIME: float = 0.25
const HOLD_TIME_THRESHOLD: float = 0.20

const SPEED: float = 5.0
const ACCELERATION: float = 40.0
const FRICTION: float = 25.0


# --- DATA TRACKING & SYSTEM REFS ---
var move_input: Vector2 = Vector2.ZERO
var raw_direction: Vector3 = Vector3.ZERO

var action_hold_time: float = 0.0
var is_holding_action: bool = false

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


# --- ENGINE RUNTIME LOOPS ---
func _process(_delta: float) -> void:
	move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	raw_direction = Vector3(move_input.x, 0.0, move_input.y).normalized()
