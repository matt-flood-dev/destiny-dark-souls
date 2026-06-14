extends CharacterBody3D
class_name Player

# --- SIGNALS ---

signal health_changed(current: float, max_val: float)
signal ammo_changed(current: int, max_val: int)
signal weapon_fired(status_text: String)
signal weapon_hit(info_text: String)


# --- CONFIGURATION & EXPORTS ---

const SPEED: float = 5.0
const ACCELERATION: float = 40.0
const FRICTION: float = 25.0
const JUMP_VELOCITY: float = 4.5

@export var mouse_sensitivity: float = 0.002
@export var camera_lerp_speed: float = 10.0

@export_group("Health Settings")
@export var max_health: float = 100.0

@export_group("Weapon Settings")
@export var fire_rate: float = 0.5
@export var max_ammo: int = 12
@export var reload_time: float = 1.5

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

var current_ammo: int = 12
var fire_timer: float = 0.0
var is_reloading: bool = false

var move_input: Vector2 = Vector2.ZERO
var raw_direction: Vector3 = Vector3.ZERO
var forward: Vector3 = Vector3.ZERO
var right: Vector3 = Vector3.ZERO

var mouse_input: Vector2 = Vector2.ZERO
var target_camera_y: float = 0.8

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera:  Camera3D = $Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var weapon_raycast: RayCast3D = $Camera3D/WeaponRayCast


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	current_health = max_health

	await get_tree().process_frame
	health_changed.emit(current_health, max_health)
	ammo_changed.emit(current_ammo, max_ammo)

	weapon_fired.emit("WEAPON: Standby")


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

	if event.is_action_pressed("shoot") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if is_reloading:
			return

		if fire_timer <= 0.0 and current_ammo > 0:
			_fire_weapon()
		elif current_ammo <= 0:
			weapon_fired.emit("WEAPON: Out of Ammo")

	if event.is_action_released("shoot"):
		if not is_reloading:
			weapon_fired.emit("WEAPON: Standby")

	if event.is_action_pressed("reload") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not is_reloading and current_ammo < max_ammo:
			_reload_weapon()


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

	if fire_timer > 0.0:
			fire_timer -= delta


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


func _fire_weapon() -> void:
	fire_timer = fire_rate
	current_ammo -= 1

	ammo_changed.emit(current_ammo, max_ammo)
	weapon_fired.emit("WEAPON: Fired")
	print("Weapon fired!")

	if not weapon_raycast:
		return

	weapon_raycast.force_raycast_update()

	if weapon_raycast.is_colliding():
		var target = weapon_raycast.get_collider()

		weapon_hit.emit("HIT: " + target.name)

		if target.has_method("take_damage"):
			target.take_damage(15.0)
	else:
		weapon_hit.emit("HIT: Miss")


func _reload_weapon() -> void:
	is_reloading = true
	weapon_fired.emit("WEAPON: Reloading")
	print("Reload started")

	await get_tree().create_timer(reload_time).timeout

	if not is_inside_tree():
		return

	current_ammo = max_ammo
	is_reloading = false
	
	ammo_changed.emit(current_ammo, max_ammo)
	weapon_fired.emit("WEAPON: Standby")
	print("Reload completed")
