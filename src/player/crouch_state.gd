extends PlayerState
class_name CrouchState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var crouch_move_speed: float = 2.5
@export var crouch_height: float = 1.0
@export var stand_height: float = 2.0

@export var camera_crouch_y: float = 0.4
@export var camera_stand_y: float = 0.8


# --- DATA & REFERENCES ---

var collision_shape: CollisionShape3D
var just_entered: bool = true

var is_slipping: bool = false
var slip_timer: float = 0.0
var slip_direction: Vector3 = Vector3.ZERO

var fault_slip_state: FaultSlipState


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)
	if not player:
		return

	if just_entered:
		just_entered = false
		return

	if is_slipping and fault_slip_state:
		slip_timer += delta
		if slip_timer >= fault_slip_state.slip_duration:
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
	if not player:
		return

	apply_gravity(delta)

	if is_slipping and fault_slip_state:
		player.velocity.x = slip_direction.x * fault_slip_state.slip_speed
		player.velocity.z = slip_direction.z * fault_slip_state.slip_speed
	else:
		if player.move_input != Vector2.ZERO:
			var target_velocity: Vector3 = player.raw_direction * crouch_move_speed
			player.velocity.x = move_toward(player.velocity.x, target_velocity.x, player.ACCELERATION * delta)
			player.velocity.z = move_toward(player.velocity.z, target_velocity.z, player.ACCELERATION * delta)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0.0, player.FRICTION * delta)
			player.velocity.z = move_toward(player.velocity.z, 0.0, player.FRICTION * delta)

# --- PUBLIC METHODS ---

func enter() -> void:
	print("Player entered Crouch state.")
	just_entered = true

	can_double_jump = false
	can_air_dodge = true

	if player:
		player.target_camera_y = camera_crouch_y

		collision_shape = player.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision_shape and collision_shape.shape is CapsuleShape3D:
			collision_shape.shape.height = crouch_height
			collision_shape.position.y = -0.25

	if state_machine:
		fault_slip_state = state_machine.get_node_or_null("FaultSlip") as FaultSlipState


func exit() -> void:
	print("Player exited Crouch state.")

	if is_slipping:
		is_slipping = false

	if player:
		player.target_camera_y = camera_stand_y

	if collision_shape and collision_shape.shape is CapsuleShape3D:
		collision_shape.shape.height = stand_height
		collision_shape.position.y = 0.0


# --- PRIVATE METHODS ---
