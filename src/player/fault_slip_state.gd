extends PlayerState
class_name FaultSlipState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

const AMBIENT_RAD_COST: float = 10.0

var slip_direction: Vector3 = Vector3.ZERO
var current_time: float = 0.0


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)

	current_time += delta

	if current_time >= player.slip_duration:
		if player.move_input != Vector2.ZERO:
			state_machine.change_state("Move")
			return
		else:
			state_machine.change_state("Idle")
			return


func physics_update(_delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state("Fall")
		return

	player.velocity.y = 0.0

	player.velocity.x = slip_direction.x * player.slip_speed
	player.velocity.z = slip_direction.z * player.slip_speed


# --- PUBLIC METHODS ---

func enter() -> void:
	var tarc: TarcManager = player.get_node_or_null("TarcManager")
	if not tarc or not tarc.consume_ambient_rad(AMBIENT_RAD_COST):
		if player.move_input != Vector2.ZERO:
			state_machine.change_state("Move")
		else:
			state_machine.change_state("Idle")
		return

	print("Player entered FaultSlip state.")

	current_time = 0.0

	if player.raw_direction != Vector3.ZERO:
		slip_direction = player.raw_direction
	else:
		slip_direction = player.global_transform.basis.z.normalized()


func exit() -> void:
	print("Player exited FaultSlip state.")

	player.velocity.x *= 0.5
	player.velocity.z *= 0.5


# --- PRIVATE METHODS ---
