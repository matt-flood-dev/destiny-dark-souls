extends PlayerState
class_name SlideState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

var slide_direction: Vector3 = Vector3.ZERO
var current_time: float = 0.0


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)

	current_time += delta

	if current_time >= player.slide_duration:
		state_machine.change_state("Crouch")
		return


func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state("Fall")
		return

	player.velocity.y = 0.0

	player.velocity.x = player.velocity.x * exp(-player.slide_friction * delta)
	player.velocity.z = player.velocity.z * exp(-player.slide_friction * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	DebugSettings.log("Player entered Slide state.")

	current_time = 0.0

	if player.raw_direction != Vector3.ZERO:
		slide_direction = player.raw_direction
	else:
		slide_direction = -player.global_transform.basis.z.normalized()

	var initial_slide_speed: float = player.SPEED * player.slide_boost_multiplier
	player.velocity.x = slide_direction.x * initial_slide_speed
	player.velocity.z = slide_direction.z * initial_slide_speed

	player.target_camera_y = player.camera_crouch_y

	player.set_collision_height(player.crouch_height)


func exit() -> void:
	DebugSettings.log("Player exited Slide state.")


# --- PRIVATE METHODS ---
