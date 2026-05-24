extends Node
class_name StateMachine

# =============================================================================
# CONFIGURATIONS & STATES
# =============================================================================
@export var initial_state: PlayerState

var current_state: PlayerState
var states: Dictionary = {}


# =============================================================================
# ENGINE RUNTIME LOOPS
# =============================================================================
func _ready() -> void:
	await owner.ready

	for child in get_children():
		if child is PlayerState:
			states[child.name.to_lower()] = child
			child.player = owner as Player

	if initial_state:
		current_state = initial_state
		current_state.enter()
