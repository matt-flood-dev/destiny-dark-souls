extends PlayerState
class_name CrouchState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

var just_entered: bool = true

var is_slipping: bool = false
var slip_timer: float = 0.0
var slip_direction: Vector3 = Vector3.ZERO


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)

	if just_entered:
		just_entered = false
		return

	if is_slipping:
		slip_timer += delta
		if slip_timer >= player.slip_duration:
			is_slipping = false
			player.velocity.x *= 0.5
			player.velocity.z *= 0.5
		return

	if Input.is_action_just_pressed("dodge"):
		is_slipping = true
		slip_timer = 0.0
		if player.raw_direction != Vector3.ZERO:
			slip_direction = player.raw_direction
		else:
			slip_direction = player.global_transform.basis.z.normalized()
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("Jump")
		return

	if Input.is_action_just_pressed("crouch"):
		if player.move_input != Vector2.ZERO:
			state_machine.change_state("Move")
			return
		else:
			state_machine.change_state("Idle")
			return


func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state("Fall")
		return

	player.velocity.y = 0.0

	if is_slipping:
		player.velocity.x = slip_direction.x * player.slip_speed
		player.velocity.z = slip_direction.z * player.slip_speed
	else:
		if player.move_input != Vector2.ZERO:
			var target_velocity: Vector3 = player.raw_direction * player.crouch_move_speed
			player.velocity.x = move_toward(player.velocity.x, target_velocity.x, player.ACCELERATION * delta)
			player.velocity.z = move_toward(player.velocity.z, target_velocity.z, player.ACCELERATION * delta)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0.0, player.FRICTION * delta)
			player.velocity.z = move_toward(player.velocity.z, 0.0, player.FRICTION * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	print("Player entered Crouch state.")
	just_entered = true

	player.target_camera_y = player.camera_crouch_y

	player.set_collision_height(player.crouch_height)


func exit() -> void:
	print("Player exited Crouch state.")

	if is_slipping:
		is_slipping = false

	player.target_camera_y = player.camera_stand_y

	player.set_collision_height(player.stand_height)


# --- PRIVATE METHODS ---
