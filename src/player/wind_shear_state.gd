extends PlayerState
class_name WindShearState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var shear_speed: float = 18.0
@export var shear_duration: float = 0.4
@export var shear_friction: float = 2.5


# --- DATA & REFERENCES ---

var shear_direction: Vector3 = Vector3.ZERO
var current_time: float = 0.0
var has_sheared: bool = false


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)
	if not player:
		return

	current_time += delta

	if player.is_on_floor():
		has_sheared = false
		if player.move_input != Vector2.ZERO:
			state_machine.change_state("Move")
		else:
			state_machine.change_state("Idle")
		return

	if Input.is_action_just_pressed("jump") and can_double_jump:
		can_double_jump = false
		state_machine.change_state("GravShift")
		return

	if current_time >= shear_duration:
		state_machine.change_state("Fall")


func physics_update(delta: float) -> void:
	if not player:
		return

	player.velocity.y = 0.0

	player.velocity.x = player.velocity.x * exp(-shear_friction * delta)
	player.velocity.z = player.velocity.z * exp(-shear_friction * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	print("Player entered WindShear state.")
	if not player:
		return

	current_time = 0.0
	has_sheared = true

	player.velocity.y = 0.0

	if player.raw_direction != Vector3.ZERO:
		shear_direction = player.raw_direction
	else:
		var forward_vector: Vector3 = -player.camera.global_transform.basis.z
		forward_vector.y = 0.0
		shear_direction = forward_vector.normalized()

	player.velocity.x = shear_direction.x * shear_speed
	player.velocity.z = shear_direction.z * shear_speed


func exit() -> void:
	print("Player exited WindShear state.")


# --- PRIVATE METHODS ---
