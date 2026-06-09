extends PlayerState
class_name IdleState

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

	if player.move_input != Vector2.ZERO:
		state_machine.change_state("Move")
		return


func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state("Fall")
		return

	player.velocity.y = 0.0

	player.velocity.x = move_toward(player.velocity.x, 0.0, player.FRICTION * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, player.FRICTION * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	print("Player entered Idle state.")


func exit() -> void:
	print("Player exited Idle state.")


# --- PRIVATE METHODS ---
