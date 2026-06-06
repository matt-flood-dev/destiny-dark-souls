extends CharacterBody3D
class_name Player

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

const SPEED: float = 5.0
const ACCELERATION: float = 40.0
const FRICTION: float = 25.0
const JUMP_VELOCITY: float = 4.5

@export var mouse_sensitivity: float = 0.002
@export var camera_lerp_speed: float = 10.0


# --- DATA & REFERENCES ---

var move_input: Vector2 = Vector2.ZERO
var raw_direction: Vector3 = Vector3.ZERO
var forward: Vector3 = Vector3.ZERO
var right: Vector3 = Vector3.ZERO

var mouse_input: Vector2 = Vector2.ZERO
var target_camera_y: float = 0.8

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera:  Camera3D = $Camera3D
@onready var tarc_manager: TarcManager = $TarcManager


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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


# --- PRIVATE METHODS ---

func _handle_look_rotation() -> void:
	if mouse_input != Vector2.ZERO:
		rotate_y(-mouse_input.x * mouse_sensitivity)
		camera.rotate_x(-mouse_input.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))
		mouse_input = Vector2.ZERO
