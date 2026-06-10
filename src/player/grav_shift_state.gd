extends PlayerState
class_name GravShiftState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

const AMBIENT_RAD_COST: float = 10.0

var current_air_speed: float = 5.0


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)

	if Input.is_action_just_pressed("dodge") and can_air_dodge:
		var tarc: TarcManager = player.get_node_or_null("TarcManager")
		if tarc and tarc.current_ambient_rad >= AMBIENT_RAD_COST:
			state_machine.change_state("WindShear")
			return


func physics_update(delta: float) -> void:
	if has_landed():
		return

	apply_gravity(delta)

	if player.velocity.y <= 0.0:
		state_machine.change_state("Fall")
		return

	var target_velocity: Vector3 = player.raw_direction * current_air_speed
	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, player.ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, player.ACCELERATION * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	var tarc: TarcManager = player.get_node_or_null("TarcManager")
	if not tarc or not tarc.consume_ambient_rad(AMBIENT_RAD_COST):
		state_machine.change_state("Fall")
		return

	print("Player entered GravShift state.")

	player.velocity.y = player.JUMP_VELOCITY

	var horizontal_velocity: Vector2 = Vector2(player.velocity.x, player.velocity.z)
	current_air_speed = horizontal_velocity.length()

	if current_air_speed < player.SPEED:
		current_air_speed = player.SPEED


func exit() -> void:
	print("Player exited GravShift state.")


# --- PRIVATE METHODS ---
