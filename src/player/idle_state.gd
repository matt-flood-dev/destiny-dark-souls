extends PlayerState

# --- STATE LIFECYCLE LOOPS ---
func enter() -> void:
	print("Player entered Idle state.")


func exit() -> void:
	print("Player exited Idle state.")


# --- ENGINE RUNTIME LOOPS ---
func update(_delta: float) -> void:
	if not player:
		return

	if player.move_input != Vector2.ZERO:
		state_machine.change_state("move")


func physics_update(delta: float) -> void:
	if not player:
		return

	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	player.velocity.x = move_toward(player.velocity.x, 0.0, player.FRICTION * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, player.FRICTION * delta)
	
	player.move_and_slide()
