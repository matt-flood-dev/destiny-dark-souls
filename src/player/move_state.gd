extends PlayerState
class_name MoveState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)

	if Input.is_action_just_pressed("dodge"):
		state_machine.change_state("FaultSlip")
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("Jump")
		return
		
	if Input.is_action_just_pressed("crouch"):
		state_machine.change_state("Crouch")
		return

	if player.move_input == Vector2.ZERO:
		state_machine.change_state("Idle")
		return

	if Input.is_action_pressed("sprint") and player.move_input.y < 0 and player.move_input.x == 0:
		state_machine.change_state("Sprint")
		return


func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state("Fall")
		return

	player.velocity.y = 0.0

	var target_velocity: Vector3 = player.raw_direction * player.SPEED
	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, player.ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, player.ACCELERATION * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	DebugSettings.log("Player entered Move state.")


func exit() -> void:
	DebugSettings.log("Player exited Move state.")


# --- PRIVATE METHODS ---
