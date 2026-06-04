extends PlayerState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var slide_boost_multiplier: float = 2.4
@export var slide_friction: float = 4.5
@export var slide_duration: float = 0.8

@export var crouch_height: float = 1.0
@export var stand_height: float = 2.0
@export var camera_crouch_y: float = 0.4


# --- DATA & REFERENCES ---

var slide_direction: Vector3 = Vector3.ZERO
var current_time: float = 0.0
var collision_shape: CollisionShape3D


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)
	if not player:
		return

	current_time += delta

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_state("jump")
		return

	if current_time >= slide_duration:
		state_machine.change_state("crouch")
		return


func physics_update(delta: float) -> void:
	if not player:
		return

	apply_gravity(delta)

	var target_velocity: Vector3 = Vector3.ZERO
	
	player.velocity.x = lerp(player.velocity.x, target_velocity.x, slide_friction * delta)
	player.velocity.z = lerp(player.velocity.z, target_velocity.z, slide_friction * delta)


# --- PUBLIC METHODS ---

func enter() -> void:
	print("Player entered Slide state.")
	if player:
		current_time = 0.0

		if player.raw_direction != Vector3.ZERO:
			slide_direction = player.raw_direction
		else:
			slide_direction = -player.global_transform.basis.z.normalized()

		var initial_slide_speed: float = player.SPEED * slide_boost_multiplier
		player.velocity.x = slide_direction.x * initial_slide_speed
		player.velocity.z = slide_direction.z * initial_slide_speed

		player.target_camera_y = camera_crouch_y

		collision_shape = player.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision_shape and collision_shape.shape is CapsuleShape3D:
			collision_shape.shape.height = crouch_height
			collision_shape.position.y = -0.25


func exit() -> void:
	print("Player exited Slide state.")


# --- PRIVATE METHODS ---
