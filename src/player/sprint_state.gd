extends PlayerState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var sprint_multiplier: float = 1.6


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

	if not Input.is_action_pressed("sprint"):
		state_machine.change_state("move")
		return

	if player.move_input == Vector2.ZERO:
		state_machine.change_state("idle")
		return


func physics_update(delta: float) -> void:
	if not player:
		return

	apply_gravity(delta)

	var target_velocity: Vector3 = player.raw_direction * (player.SPEED * sprint_multiplier)

	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, player.ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, player.ACCELERATION * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	print("Player entered Sprint state.")


func exit() -> void:
	print("Player exited Sprint state.")


# --- PRIVATE METHODS ---
