extends Node
class_name LoadoutManager

# --- SIGNALS ---

signal ammo_changed(current: int, max_val: int)
signal active_weapon_changed(configuration: WeaponDefinitions.Configuration)
signal reload_finished()
signal magazines_refilled(configuration: WeaponDefinitions.Configuration)
signal magazine_slot_added(configuration: WeaponDefinitions.Configuration, magazine_count: int)


# --- CONFIGURATION & EXPORTS ---

const WEAPON_BASE_SCRIPT: Script = preload("res://src/weapons/weapon_base.gd")

@export var starting_weapon_data: WeaponData
@export var weapon_socket: Marker3D


# --- DATA & REFERENCES ---

var fire_timer: float = 0.0
var is_reloading: bool = false

var unlocked_configurations: Array[WeaponDefinitions.Configuration] = [
	WeaponDefinitions.Configuration.PISTOL_SIDEARM,
]

var equipped_frames: Array[WeaponDefinitions.Frame] = [
	WeaponDefinitions.Frame.PISTOL,
]

var frame_configuration: Dictionary = {
	WeaponDefinitions.Frame.PISTOL: WeaponDefinitions.Configuration.PISTOL_SIDEARM,
}

var active_slot_index: int = 0
var magazine_states: Dictionary = {}
var weapon_data_registry: Dictionary = {}
var collected_magazine_pickup_ids: Array[String] = []

var _active_weapon: WeaponBase = null
var _active_weapon_data: WeaponData = null
var _active_magazine_state: MagazineState = null


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	_resolve_weapon_socket()
	_initialize_starting_loadout()


func _process(delta: float) -> void:
	if fire_timer > 0.0:
		fire_timer -= delta


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func register_weapon_data(data: WeaponData) -> void:
	if not data:
		return

	weapon_data_registry[data.configuration] = data


func get_active_configuration() -> WeaponDefinitions.Configuration:
	if equipped_frames.is_empty():
		return WeaponDefinitions.Configuration.PISTOL_SIDEARM

	var active_frame: WeaponDefinitions.Frame = equipped_frames[active_slot_index]
	return frame_configuration.get(active_frame, WeaponDefinitions.Configuration.PISTOL_SIDEARM) as WeaponDefinitions.Configuration


func get_active_weapon_data() -> WeaponData:
	return _active_weapon_data


func get_active_weapon() -> WeaponBase:
	return _active_weapon


func get_gun_rounds() -> int:
	if not _active_magazine_state:
		return 0

	return _active_magazine_state.get_gun_rounds()


func get_gun_capacity() -> int:
	if not _active_magazine_state:
		return 0

	return _active_magazine_state.get_gun_capacity()


func has_any_ammo() -> bool:
	if not _active_magazine_state:
		return false

	return _active_magazine_state.has_any_ammo()


func is_completely_dry() -> bool:
	return not has_any_ammo()


func can_fire() -> bool:
	return fire_timer <= 0.0 and get_gun_rounds() > 0 and not is_reloading


func can_reload() -> bool:
	if is_reloading or not _active_magazine_state:
		return false

	return _active_magazine_state.can_reload()


func equip_active_weapon() -> void:
	_clear_active_weapon()

	var configuration: WeaponDefinitions.Configuration = get_active_configuration()
	_active_weapon_data = weapon_data_registry.get(configuration) as WeaponData

	if not _active_weapon_data:
		push_error("LoadoutManager: No WeaponData registered for configuration " + str(configuration) + ".")
		return

	if not magazine_states.has(configuration):
		_create_magazine_state(_active_weapon_data)

	_active_magazine_state = magazine_states[configuration] as MagazineState
	_spawn_weapon(_active_weapon_data)
	_emit_ammo_changed()
	active_weapon_changed.emit(configuration)


func try_fire(weapon_raycast: RayCast3D) -> Dictionary:
	var result: Dictionary = {
		"fired": false,
		"hit": false,
		"target_name": "",
	}

	if not can_fire():
		return result

	if _active_weapon and not _active_weapon.play_fire():
		return result

	_active_magazine_state.consume_round()
	fire_timer = _get_fire_cooldown_duration()
	_emit_ammo_changed()

	var hit_result: Dictionary = _perform_hitscan(weapon_raycast)
	result["fired"] = true
	result["hit"] = hit_result["hit"]
	result["target_name"] = hit_result["target_name"]
	return result


func start_reload() -> void:
	if is_reloading or not can_reload() or not _active_weapon_data:
		return

	is_reloading = true
	_reload_after_delay()


func play_weapon_idle() -> void:
	if _active_weapon:
		_active_weapon.play_idle()


func stop_weapon_idle() -> void:
	if _active_weapon:
		_active_weapon.stop_idle()


func is_configuration_unlocked(configuration: WeaponDefinitions.Configuration) -> bool:
	return configuration in unlocked_configurations


func get_magazine_state(configuration: WeaponDefinitions.Configuration) -> MagazineState:
	return magazine_states.get(configuration) as MagazineState


func can_add_magazine_slot(configuration: WeaponDefinitions.Configuration) -> bool:
	if not is_configuration_unlocked(configuration):
		return false

	var state: MagazineState = get_magazine_state(configuration)
	if not state:
		return false

	return state.can_add_magazine_slot()


func try_add_magazine_slot(configuration: WeaponDefinitions.Configuration) -> bool:
	if not can_add_magazine_slot(configuration):
		return false

	var state: MagazineState = get_magazine_state(configuration)
	if not state:
		return false

	if not state.add_magazine_slot():
		return false

	magazine_slot_added.emit(configuration, state.get_magazine_count())

	if DebugSettings.ENABLED:
		var data: WeaponData = get_weapon_data(configuration)
		var weapon_name: String = data.display_name if data else str(configuration)
		DebugSettings.log(
			"LoadoutManager: Added magazine slot for "
			+ weapon_name
			+ " ("
			+ str(state.get_magazine_count())
			+ "/"
			+ str(state.max_magazine_count)
			+ ")"
		)

	return true


func has_collected_magazine_pickup(pickup_id: String) -> bool:
	if pickup_id.is_empty():
		return false

	return pickup_id in collected_magazine_pickup_ids


func mark_magazine_pickup_collected(pickup_id: String) -> void:
	if pickup_id.is_empty() or pickup_id in collected_magazine_pickup_ids:
		return

	collected_magazine_pickup_ids.append(pickup_id)


func get_unlocked_configurations() -> Array[WeaponDefinitions.Configuration]:
	return unlocked_configurations.duplicate()


func get_weapon_data(configuration: WeaponDefinitions.Configuration) -> WeaponData:
	return weapon_data_registry.get(configuration) as WeaponData


func get_refill_cost(configuration: WeaponDefinitions.Configuration, rounds: int) -> int:
	if rounds <= 0:
		return 0

	var data: WeaponData = get_weapon_data(configuration)
	if not data:
		return 0

	return rounds * data.soulite_cost_per_round


func get_fill_magazine_cost(configuration: WeaponDefinitions.Configuration, magazine_index: int) -> int:
	var state: MagazineState = get_magazine_state(configuration)
	if not state:
		return 0

	return get_refill_cost(configuration, state.get_missing_rounds(magazine_index))


func try_refill_magazine_rounds(
	configuration: WeaponDefinitions.Configuration,
	magazine_index: int,
	rounds: int,
	soulite_manager: SouliteManager
) -> int:
	if rounds <= 0 or not soulite_manager:
		return 0

	if not is_configuration_unlocked(configuration):
		return 0

	var state: MagazineState = get_magazine_state(configuration)
	var data: WeaponData = get_weapon_data(configuration)
	if not state or not data:
		return 0

	var missing_rounds: int = state.get_missing_rounds(magazine_index)
	if missing_rounds <= 0:
		return 0

	var rounds_to_add: int = mini(rounds, missing_rounds)
	var cost: int = get_refill_cost(configuration, rounds_to_add)
	if cost <= 0:
		return 0

	if not soulite_manager.spend_soulite(cost):
		return 0

	var added_rounds: int = state.add_rounds(magazine_index, rounds_to_add)
	if added_rounds <= 0:
		return 0

	if configuration == get_active_configuration():
		_emit_ammo_changed()

	magazines_refilled.emit(configuration)
	return added_rounds


func try_fill_magazine(
	configuration: WeaponDefinitions.Configuration,
	magazine_index: int,
	soulite_manager: SouliteManager
) -> int:
	var state: MagazineState = get_magazine_state(configuration)
	if not state:
		return 0

	return try_refill_magazine_rounds(
		configuration,
		magazine_index,
		state.get_missing_rounds(magazine_index),
		soulite_manager
	)


# --- PRIVATE METHODS ---

func _resolve_weapon_socket() -> void:
	if weapon_socket:
		return

	weapon_socket = get_node_or_null("../Camera3D/WeaponSocket") as Marker3D

	if not weapon_socket:
		push_error("LoadoutManager: weapon_socket is not assigned and could not be found at Camera3D/WeaponSocket.")


func _initialize_starting_loadout() -> void:
	if starting_weapon_data:
		register_weapon_data(starting_weapon_data)
		_create_magazine_state(starting_weapon_data)


func _create_magazine_state(data: WeaponData) -> void:
	var state: MagazineState = MagazineState.new()
	state.setup_initial(data)
	magazine_states[data.configuration] = state


func _spawn_weapon(data: WeaponData) -> void:
	if not data.weapon_scene:
		push_error("LoadoutManager: WeaponData '" + data.display_name + "' has no weapon_scene.")
		return

	if not weapon_socket:
		push_error("LoadoutManager: weapon_socket is not assigned.")
		return

	var weapon_instance: Node3D = data.weapon_scene.instantiate() as Node3D
	if not weapon_instance:
		push_error("LoadoutManager: Failed to instantiate weapon scene for '" + data.display_name + "'.")
		return

	weapon_instance.set_script(WEAPON_BASE_SCRIPT)
	_active_weapon = weapon_instance as WeaponBase

	if not _active_weapon:
		push_error("LoadoutManager: Failed to attach WeaponBase script for '" + data.display_name + "'.")
		weapon_instance.queue_free()
		return

	_active_weapon.configure(data)
	weapon_socket.add_child(weapon_instance)


func _clear_active_weapon() -> void:
	if _active_weapon and is_instance_valid(_active_weapon):
		_active_weapon.queue_free()

	_active_weapon = null


func _get_fire_cooldown_duration() -> float:
	if _active_weapon:
		var animation_duration: float = _active_weapon.get_fire_cooldown_duration()
		if animation_duration > 0.0:
			return animation_duration

	if _active_weapon_data:
		return _active_weapon_data.fire_rate

	return 0.5


func _perform_hitscan(weapon_raycast: RayCast3D) -> Dictionary:
	var result: Dictionary = {
		"hit": false,
		"target_name": "",
		"damage": 0.0,
	}

	if not weapon_raycast or not _active_weapon_data:
		return result

	weapon_raycast.force_raycast_update()

	if not weapon_raycast.is_colliding():
		return result

	var target = weapon_raycast.get_collider()
	result["hit"] = true
	result["target_name"] = target.name
	result["damage"] = _active_weapon_data.damage

	if target.has_method("take_damage"):
		target.take_damage(_active_weapon_data.damage)

	return result


func _reload_after_delay() -> void:
	var reload_duration: float = _active_weapon_data.reload_time
	await get_tree().create_timer(reload_duration).timeout

	if not is_inside_tree():
		return

	is_reloading = false

	if not _active_magazine_state:
		return

	if _active_magazine_state.perform_reload_swap():
		_emit_ammo_changed()

	reload_finished.emit()


func _emit_ammo_changed() -> void:
	ammo_changed.emit(get_gun_rounds(), get_gun_capacity())
