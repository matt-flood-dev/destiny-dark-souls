extends PlayerState

# =============================================================================
# ENGINE RUNTIME LOOPS
# =============================================================================
func enter() -> void:
	print("Player entered Idle state.")


func exit() -> void:
	print("Player exited Idle state.")


func update(_delta: float) -> void:
	if not player:
		return

	if player.move_input != Vector2.ZERO:
		state_machine.change_state("move")
