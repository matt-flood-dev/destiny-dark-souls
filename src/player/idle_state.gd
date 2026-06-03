extends PlayerState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)
	if not player:
		return

	if Input.is_action_just_pressed("dodge"):
		state_machine.change_state("fault_slip")
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jump")
		return

	if Input.is_action_just_pressed("crouch"):
		state_machine.change_state("crouch")
		return

	if player.move_input != Vector2.ZERO:
		if Input.is_action_pressed("sprint"):
			state_machine.change_state("sprint")
			return
		else:
			state_machine.change_state("move")
			return


func physics_update(delta: float) -> void:
	if not player:
		return

	apply_gravity(delta)

	player.velocity.x = move_toward(player.velocity.x, 0.0, player.FRICTION * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, player.FRICTION * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	print("Player entered Idle state.")


func exit() -> void:
	print("Player exited Idle state.")


# --- PRIVATE METHODS ---
