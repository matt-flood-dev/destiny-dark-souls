extends PlayerState

var current_air_speed: float = 5.0

# --- ENGINE RUNTIME LOOPS ---
func enter() -> void:
	print("Player entered Jump state.")
	if player:
		player.velocity.y = player.JUMP_VELOCITY

		var horizontal_velocity: Vector2 = Vector2(player.velocity.x, player.velocity.z)
		current_air_speed = horizontal_velocity.length()

		if current_air_speed < player.SPEED:
			current_air_speed = player.SPEED


func exit() -> void:
	print("Player exited Jump state.")


func update(delta: float) -> void:
	super(delta)

	if not player:
		return

	if player.is_on_floor():
		if player.move_input != Vector2.ZERO:
			if Input.is_action_pressed("sprint"):
				state_machine.change_state("sprint")
				return
			else:
				state_machine.change_state("move")
				return
		else:
			state_machine.change_state("idle")
			return


func physics_update(delta: float) -> void:
	if not player:
		return

	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	var target_velocity: Vector3 = player.raw_direction * current_air_speed

	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, player.ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, player.ACCELERATION * delta)

	player.move_and_slide()
