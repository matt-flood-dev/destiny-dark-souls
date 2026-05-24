extends PlayerState

# =============================================================================
# ENGINE RUNTIME LOOPS
# =============================================================================
func enter() -> void:
	print("Player entered Move state.")


func exit() -> void:
	print("Player exited Move state.")


func update(_delta: float) -> void:
	var move_input: Vector2 = Input.get_vector("move_forward", "move_backward", "move_left", "move_right")
	
	if move_input == Vector2.ZERO:
		state_machine.change_state("idle")
