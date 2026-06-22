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
var _is_dead: bool = false

var move_input: Vector2 = Vector2.ZERO
var raw_direction: Vector3 = Vector3.ZERO
var forward: Vector3 = Vector3.ZERO
var right: Vector3 = Vector3.ZERO

var mouse_input: Vector2 = Vector2.ZERO
var target_camera_y: float = 0.8

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera: Camera3D = $Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var weapon_raycast: RayCast3D = $Camera3D/WeaponRayCast
@onready var interact_raycast: RayCast3D = $Camera3D/InteractRayCast
@onready var loadout_manager: LoadoutManager = $LoadoutManager
@onready var soulite_manager: SouliteManager = $SouliteManager
@onready var interaction_manager: InteractionManager = $InteractionManager
@onready var tarc_manager: TarcManager = $TarcManager
@onready var hud_layer: HUDLayer = $HUDLayer


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_health = max_health

	_apply_bonfire_respawn_position()

	loadout_manager.ammo_changed.connect(_on_loadout_ammo_changed)
	loadout_manager.reload_finished.connect(_on_loadout_reload_finished)
	loadout_manager.active_weapon_changed.connect(_on_active_weapon_changed)
	loadout_manager.loadout_changed.connect(_on_loadout_changed)
	interaction_manager.setup(self, interact_raycast)
	tarc_manager.melee_activated.connect(_on_melee_activated)
	tarc_manager.grenade_activated.connect(_on_grenade_activated)

	await get_tree().process_frame
	health_changed.emit(current_health, max_health)
	loadout_manager.equip_active_weapon()

	weapon_fired.emit("WEAPON: Standby")

	if CheckpointManager.should_show_death_screen():
		await _show_post_death_screen()


# --- INPUT HANDLING ---

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input = event.relative

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if DebugSettings.ENABLED and event.is_action_pressed("restart_scene"):
		get_tree().reload_current_scene()
		return

	if DebugSettings.ENABLED and (event.is_action_pressed("ui_text_backspace") or (event is InputEventKey and event.pressed and event.keycode == KEY_Q)):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			get_tree().quit()

	if event.is_action_pressed("shoot") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not _is_combat_input_blocked():
			_try_fire_weapon()

	if event.is_action_released("shoot"):
		if not loadout_manager.is_reloading:
			_update_weapon_status_label()

	if event.is_action_pressed("reload") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not _is_combat_input_blocked():
			interaction_manager.begin_interact_hold()

	if event.is_action_released("reload"):
		var interact_consumed: bool = interaction_manager.complete_interact_hold()

		if _is_combat_input_blocked():
			return

		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return

		if not interact_consumed:
			_try_reload_weapon()

	if event.is_action_pressed("swap_weapon") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not _is_combat_input_blocked():
			_try_swap_weapon(event)


# --- UPDATE LOOPS ---

func _process(delta: float) -> void:
	if is_gameplay_blocked():
		move_input = Vector2.ZERO
		raw_direction = Vector3.ZERO
		mouse_input = Vector2.ZERO
	else:
		_handle_look_rotation()
		interaction_manager.process_hold(delta)

	if camera:
		camera.position.y = lerp(camera.position.y, target_camera_y, camera_lerp_speed * delta)

	if is_gameplay_blocked():
		return

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


func _physics_process(delta: float) -> void:
	if is_gameplay_blocked():
		if is_on_floor():
			velocity.y = 0.0

		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0.0, FRICTION * delta)

	move_and_slide()


# --- PUBLIC METHODS ---

func take_damage(amount: float) -> void:
	if _is_dead:
		return

	current_health = clampf(current_health - amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		_handle_death()


func play_weapon_idle() -> void:
	loadout_manager.play_weapon_idle()


func stop_weapon_idle() -> void:
	loadout_manager.stop_weapon_idle()


func open_checkpoint_menu(checkpoint: Checkpoint) -> void:
	if not hud_layer or not hud_layer.checkpoint_menu:
		return

	hud_layer.checkpoint_menu.open(self, checkpoint)


func is_checkpoint_menu_open() -> bool:
	return hud_layer and hud_layer.checkpoint_menu and hud_layer.checkpoint_menu.is_open()


func is_gameplay_blocked() -> bool:
	if is_checkpoint_menu_open():
		return true

	return hud_layer != null and hud_layer.is_death_screen_visible()


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
	if _is_dead:
		return

	_is_dead = true

	var carried_soulite: int = soulite_manager.current_soulite
	SouliteStainManager.register_player_death(global_position, carried_soulite)
	CheckpointManager.prepare_death_respawn(carried_soulite)
	get_tree().reload_current_scene()


func _apply_bonfire_respawn_position() -> void:
	if not CheckpointManager.consume_pending_death_respawn():
		return

	global_position = CheckpointManager.get_respawn_position()


func _show_post_death_screen() -> void:
	if not hud_layer:
		return

	var subtitle: String = CheckpointManager.consume_death_screen_message()
	hud_layer.show_death_screen("YOU DIED", subtitle)
	await get_tree().create_timer(CheckpointManager.get_death_screen_duration()).timeout
	hud_layer.hide_death_screen()


func _try_fire_weapon() -> void:
	if loadout_manager.is_reloading:
		return

	if not loadout_manager.can_fire():
		if loadout_manager.get_gun_rounds() <= 0:
			weapon_fired.emit("WEAPON: Out of Ammo")
		return

	var fire_result: Dictionary = loadout_manager.try_fire(weapon_raycast)
	if not fire_result["fired"]:
		return

	if loadout_manager.is_completely_dry():
		weapon_fired.emit("WEAPON: Out of Ammo")
	else:
		weapon_fired.emit("WEAPON: Fired")

	DebugSettings.log("Weapon fired!")

	if fire_result["hit"]:
		weapon_hit.emit("HIT: " + str(fire_result["target_name"]))
	else:
		weapon_hit.emit("HIT: Miss")


func _try_reload_weapon() -> void:
	if loadout_manager.is_completely_dry():
		weapon_fired.emit("WEAPON: Out of Ammo")
		return

	if not loadout_manager.can_reload():
		return

	weapon_fired.emit("WEAPON: Reloading")
	DebugSettings.log("Reload started")
	loadout_manager.start_reload()


func _on_loadout_ammo_changed(current: int, max_val: int) -> void:
	ammo_changed.emit(current, max_val)

	if not loadout_manager.is_reloading:
		_update_weapon_status_label()


func _on_loadout_reload_finished() -> void:
	_update_weapon_status_label()
	DebugSettings.log("Reload completed")


func _update_weapon_status_label() -> void:
	var weapon_data: WeaponData = loadout_manager.get_active_weapon_data()
	var weapon_name: String = weapon_data.display_name if weapon_data else "Weapon"

	if loadout_manager.is_completely_dry():
		weapon_fired.emit(weapon_name + ": Out of Ammo")
	else:
		weapon_fired.emit(weapon_name + ": Standby")


func _try_swap_weapon(event: InputEvent) -> void:
	if loadout_manager.is_reloading:
		return

	var swapped: bool = false

	if event is InputEventKey:
		if event.physical_keycode == KEY_1:
			swapped = loadout_manager.switch_to_slot(0)
		elif event.physical_keycode == KEY_2:
			swapped = loadout_manager.switch_to_slot(1)
		elif event.physical_keycode == KEY_3:
			swapped = loadout_manager.switch_to_slot(2)
	elif event is InputEventJoypadButton:
		swapped = loadout_manager.cycle_weapon_slot()

	if swapped:
		play_weapon_idle()
		_update_weapon_status_label()
		var weapon_data: WeaponData = loadout_manager.get_active_weapon_data()
		if weapon_data and DebugSettings.ENABLED:
			DebugSettings.log("Swapped to " + weapon_data.display_name)


func _on_loadout_changed() -> void:
	if hud_layer:
		hud_layer.sync_weapon_slots(
			loadout_manager.get_active_slot_index(),
			loadout_manager
		)

	play_weapon_idle()
	_update_weapon_status_label()


func _on_active_weapon_changed(_configuration: WeaponDefinitions.Configuration) -> void:
	if hud_layer:
		hud_layer.sync_weapon_slots(
			loadout_manager.get_active_slot_index(),
			loadout_manager
		)


func _on_melee_activated() -> void:
	if _is_combat_input_blocked():
		return

	var melee_result: Dictionary = CombatAbilities.perform_melee(self)
	weapon_fired.emit("MELEE: Struck" if melee_result["hit"] else "MELEE: Whiff")

	if melee_result["hit"]:
		var target_name: String = str(melee_result["target_name"])
		var targets_hit: int = melee_result["targets_hit"]
		if targets_hit > 1:
			weapon_hit.emit("HIT: " + target_name + " (+" + str(targets_hit - 1) + " more)")
		else:
			weapon_hit.emit("HIT: " + target_name)
	else:
		weapon_hit.emit("HIT: Miss")

	DebugSettings.log("Melee activated.")


func _on_grenade_activated() -> void:
	if _is_combat_input_blocked():
		return

	var grenade_result: Dictionary = CombatAbilities.perform_grenade(self, weapon_raycast)
	weapon_fired.emit("GRENADE: Detonated")

	if grenade_result["hit"]:
		var target_name: String = str(grenade_result["target_name"])
		var targets_hit: int = grenade_result["targets_hit"]
		if targets_hit > 1:
			weapon_hit.emit("HIT: " + target_name + " (+" + str(targets_hit - 1) + " more)")
		else:
			weapon_hit.emit("HIT: " + target_name)
	else:
		weapon_hit.emit("HIT: Miss")

	DebugSettings.log("Grenade detonated.")


func _is_combat_input_blocked() -> bool:
	return is_gameplay_blocked()
