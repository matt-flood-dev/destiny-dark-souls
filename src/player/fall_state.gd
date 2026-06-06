extends PlayerState
class_name FallState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

var current_air_speed: float = 5.0


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)
	if not player:
		return

	if Input.is_action_just_pressed("dodge"):
		var wind_shear = state_machine.get_node_or_null("WindShear") as WindShearState
		if wind_shear and not wind_shear.has_sheared:
			state_machine.change_state("WindShear")
			return

	if Input.is_action_just_pressed("jump") and can_double_jump:
		can_double_jump = false
		state_machine.change_state("GravShift")
		return

	if player.is_on_floor():
		if player.move_input != Vector2.ZERO:
			state_machine.change_state("Move")
			return
		else:
			state_machine.change_state("Idle")
			return


func physics_update(delta: float) -> void:
	if not player:
		return

	apply_gravity(delta)

	var target_velocity: Vector3 = player.raw_direction * current_air_speed
	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, player.ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, player.ACCELERATION * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	print("Player entered Fall state.")
	if player:
		var horizontal_velocity: Vector2 = Vector2(player.velocity.x, player.velocity.z)
		current_air_speed = horizontal_velocity.length()

		if current_air_speed < player.SPEED:
			current_air_speed = player.SPEED


func exit() -> void:
	print("Player exited Fall state.")


# --- PRIVATE METHODS ---
