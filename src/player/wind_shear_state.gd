extends PlayerState
class_name WindShearState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

const AMBIENT_RAD_COST: float = 10.0

var shear_direction: Vector3 = Vector3.ZERO
var current_time: float = 0.0


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)

	current_time += delta

	if Input.is_action_just_pressed("jump") and can_double_jump:
		var tarc: TarcManager = player.get_node_or_null("TarcManager")
		if tarc and tarc.current_ambient_rad >= AMBIENT_RAD_COST:
			can_double_jump = false
			state_machine.change_state("GravShift")
			return

	if current_time >= player.shear_duration:
		state_machine.change_state("Fall")


func physics_update(delta: float) -> void:
	if has_landed():
		return

	player.velocity.y = 0.0

	player.velocity.x = player.velocity.x * exp(-player.shear_friction * delta)
	player.velocity.z = player.velocity.z * exp(-player.shear_friction * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	var tarc: TarcManager = player.get_node_or_null("TarcManager")
	if not tarc or not tarc.consume_ambient_rad(AMBIENT_RAD_COST):
		state_machine.change_state("Fall")
		return

	print("Player entered WindShear state.")

	can_double_jump = true
	can_air_dodge = false

	current_time = 0.0

	player.velocity.y = 0.0

	if player.raw_direction != Vector3.ZERO:
		shear_direction = player.raw_direction
	else:
		var forward_vector: Vector3 = -player.camera.global_transform.basis.z
		forward_vector.y = 0.0
		shear_direction = forward_vector.normalized()

	player.velocity.x = shear_direction.x * player.shear_speed
	player.velocity.z = shear_direction.z * player.shear_speed


func exit() -> void:
	print("Player exited WindShear state.")


# --- PRIVATE METHODS ---
