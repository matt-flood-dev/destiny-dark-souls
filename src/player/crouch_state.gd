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

	if Input.is_action_just_pressed("dodge"):
		state_machine.change_state("FaultSlip")
		return

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_state("Jump")
		return

	if Input.is_action_pressed("sprint") and player.move_input != Vector2.ZERO:
		state_machine.change_state("Sprint")
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

	if player:
		player.target_camera_y = camera_crouch_y

		collision_shape = player.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision_shape and collision_shape.shape is CapsuleShape3D:
			collision_shape.shape.height = crouch_height
			collision_shape.position.y = -0.25

	if state_machine:
		fault_slip_state = state_machine.get_node_or_null("FaultSlip") as FaultSlipState

		var wind_shear: PlayerState = state_machine.get_node_or_null("WindShear") as WindShearState
		if wind_shear:
			wind_shear.has_sheared = false


func exit() -> void:
	print("Player exited Crouch state.")

	if player:
		player.target_camera_y = camera_stand_y

	if collision_shape and collision_shape.shape is CapsuleShape3D:
		collision_shape.shape.height = stand_height
		collision_shape.position.y = 0.0


# --- PRIVATE METHODS ---
