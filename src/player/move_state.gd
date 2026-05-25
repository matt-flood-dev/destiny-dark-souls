extends PlayerState

# =============================================================================
# ENGINE RUNTIME LOOPS
# =============================================================================
func enter() -> void:
	print("Player entered Move state.")


func exit() -> void:
	print("Player exited Move state.")


func update(_delta: float) -> void:
	if not player:
		return

	if player.move_input == Vector2.ZERO:
		state_machine.change_state("idle")
