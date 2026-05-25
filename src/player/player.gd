extends CharacterBody3D
class_name Player

# =============================================================================
# CONFIGURATIONS & TIMING THRESHOLDS
# =============================================================================
const DOUBLE_TAP_TIME: float = 0.25
const HOLD_TIME_THRESHOLD: float = 0.20


# =============================================================================
# INPUT & LOCOMOTION TRACKING DATA
# =============================================================================
var move_input: Vector2 = Vector2.ZERO
var raw_direction: Vector3 = Vector3.ZERO

var action_hold_time: float = 0.0
var is_holding_action: bool = false


# =============================================================================
# ENGINE RUNTIME LOOPS
# =============================================================================
func _process(_delta: float) -> void:
	move_input = Input.get_vector("move_forward", "move_backward", "move_left", "move_right")
