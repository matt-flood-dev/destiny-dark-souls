extends PlayerState

# --- ENGINE RUNTIME LOOPS ---
func enter() -> void:
	print("Player entered Move state.")


func exit() -> void:
	print("Player exited Move state.")


func update(delta: float) -> void:
	super(delta)

	if not player:
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jump")
		return

	if player.move_input == Vector2.ZERO:
		state_machine.change_state("idle")
		return

	if Input.is_action_pressed("sprint"):
		state_machine.change_state("sprint")
		return


func physics_update(delta: float) -> void:
	if not player:
		return

	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	var target_velocity: Vector3 = player.raw_direction * player.SPEED

	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, player.ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, player.ACCELERATION * delta)
	
	player.move_and_slide()
