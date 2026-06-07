extends PlayerState
class_name FaultSlipState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var slip_speed: float = 16.0
@export var slip_duration: float = 0.25


# --- DATA & REFERENCES ---

var slip_direction: Vector3 = Vector3.ZERO
var current_time: float = 0.0


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)
	if not player:
		return

	current_time += delta

	if current_time >= slip_duration:
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

	player.velocity.x = slip_direction.x * slip_speed
	player.velocity.z = slip_direction.z * slip_speed


# --- PUBLIC METHODS ---

func enter() -> void:
	print("Player entered FaultSlip state.")
	
	can_double_jump = false
	can_air_dodge = true
	
	if player:
		current_time = 0.0

		if player.raw_direction != Vector3.ZERO:
			slip_direction = player.raw_direction
		else:
			slip_direction = player.global_transform.basis.z.normalized()


func exit() -> void:
	print("Player exited FaultSlip state.")
	if player:
		player.velocity.x *= 0.5
		player.velocity.z *= 0.5


# --- PRIVATE METHODS ---
