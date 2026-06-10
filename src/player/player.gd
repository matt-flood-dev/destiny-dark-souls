extends CharacterBody3D
class_name Player

# --- SIGNALS ---

signal health_changed(current: float, max_val: float)


# --- CONFIGURATION & EXPORTS ---

const SPEED: float = 5.0
const ACCELERATION: float = 40.0
const FRICTION: float = 25.0
const JUMP_VELOCITY: float = 4.5

@export var mouse_sensitivity: float = 0.002
@export var camera_lerp_speed: float = 10.0

@export_group("Health Settings")
@export var max_health: float = 100.0

@export_group("Crouch Settings")
@export var crouch_move_speed: float = 2.5
@export var crouch_height: float = 1.0
@export var stand_height: float = 2.0
@export var camera_crouch_y: float = 0.4
@export var camera_stand_y: float = 0.8

@export_group("FaultSlip Settings")
@export var slip_speed: float = 16.0
@export var slip_duration: float = 0.25

@export_group("Sprint Settings")
@export var sprint_multiplier: float = 1.6

@export_group("Slide Settings")
@export var slide_boost_multiplier: float = 2.4
@export var slide_friction: float = 3.5
@export var slide_duration: float = 0.65

@export_group("WindShear Settings")
@export var shear_speed: float = 18.0
@export var shear_duration: float = 0.4
@export var shear_friction: float = 2.5


# --- DATA & REFERENCES ---

var current_health: float = 100.0

var move_input: Vector2 = Vector2.ZERO
var raw_direction: Vector3 = Vector3.ZERO
var forward: Vector3 = Vector3.ZERO
var right: Vector3 = Vector3.ZERO

var mouse_input: Vector2 = Vector2.ZERO
var target_camera_y: float = 0.8

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera:  Camera3D = $Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	current_health = max_health

	await get_tree().process_frame
	health_changed.emit(current_health, max_health)


# --- INPUT HANDLING ---

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input = event.relative

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("restart_scene"):
		get_tree().reload_current_scene()
		return

	if event.is_action_pressed("ui_text_backspace") or (event is InputEventKey and event.pressed and event.keycode == KEY_Q):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			get_tree().quit()


# --- UPDATE LOOPS ---

func _process(delta: float) -> void:
	_handle_look_rotation()

	if camera:
		camera.position.y = lerp(camera.position.y, target_camera_y, camera_lerp_speed * delta)

	move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if camera:
			var camera_basis: Basis = camera.global_transform.basis
			forward = camera_basis.z
			right = camera_basis.x

			forward.y = 0.0
			right.y = 0.0

			forward = forward.normalized()
			right = right.normalized()

	raw_direction = (right * move_input.x + forward * move_input.y).normalized()


func _physics_process(_delta: float) -> void:
	move_and_slide()


# --- PUBLIC METHODS ---

func take_damage(amount: float) -> void:
	current_health = clampf(current_health - amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		_handle_death()


func set_collision_height(target_height: float) -> void:
	if not collision_shape or not collision_shape.shape:
		push_error("Player: CollisionShape3D or its Shape resource is missing.")
		return

	if collision_shape.shape is CapsuleShape3D:
		if not collision_shape.shape.is_local_to_scene():
			collision_shape.shape = collision_shape.shape.duplicate()

		collision_shape.shape.height = target_height

		var target_y: float = (target_height - stand_height) / 2.0
		collision_shape.position.y = target_y


# --- PRIVATE METHODS ---

func _handle_look_rotation() -> void:
	if mouse_input != Vector2.ZERO:
		rotate_y(-mouse_input.x * mouse_sensitivity)
		camera.rotate_x(-mouse_input.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))
		mouse_input = Vector2.ZERO


func _handle_death() -> void:
	get_tree().reload_current_scene()
