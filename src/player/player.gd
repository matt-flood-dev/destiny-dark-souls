extends CharacterBody3D
class_name Player

# --- CONFIGURATIONS ---
const DOUBLE_TAP_TIME: float = 0.25
const HOLD_TIME_THRESHOLD: float = 0.20

const SPEED: float = 5.0
const ACCELERATION: float = 40.0
const FRICTION: float = 25.0

@export var mouse_sensitivity: float = 0.002


# --- MOVEMENT VECTORS ---
var move_input: Vector2 = Vector2.ZERO
var raw_direction: Vector3 = Vector3.ZERO
var forward: Vector3 = Vector3.ZERO
var right: Vector3 = Vector3.ZERO


# --- INPUT DATA TRACKING ---
var mouse_input: Vector2 = Vector2.ZERO
var double_tap_timer: float = 0.0
var action_hold_time: float = 0.0
var is_holding_action: bool = false


# --- SYSTEM REFS ---
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera:  Camera3D = $Camera3D


# --- ENGINE RUNTIME LOOPS ---
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input = event.relative

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


	if event.is_action_pressed("ui_text_backspace") or (event is InputEventKey and event.pressed and event.keycode == KEY_Q):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			get_tree().quit()


func _process(_delta: float) -> void:
	move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	forward = global_transform.basis.z
	right = global_transform.basis.x

	raw_direction = (right * move_input.x + forward * move_input.y).normalized()
