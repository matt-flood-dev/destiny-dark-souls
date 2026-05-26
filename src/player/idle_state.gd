extends PlayerState

# --- ENGINE RUNTIME LOOPS ---
func enter() -> void:
	print("Player entered Idle state.")


func exit() -> void:
	print("Player exited Idle state.")


func update(delta: float) -> void:
	super(delta)

	if not player:
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jump")
		return

	if player.move_input != Vector2.ZERO:
		if Input.is_action_pressed("sprint"):
			state_machine.change_state("sprint")
			return
		else:
			state_machine.change_state("move")
			return


func physics_update(delta: float) -> void:
	if not player:
		return

	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	player.velocity.x = move_toward(player.velocity.x, 0.0, player.FRICTION * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, player.FRICTION * delta)
	
	player.move_and_slide()
