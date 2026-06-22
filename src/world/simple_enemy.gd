extends CharacterBody3D
class_name SimpleEnemy

# --- SIGNALS ---

signal died(soulite_reward: int)
signal respawned()


# --- CONFIGURATION & EXPORTS ---

enum State {
	IDLE,
	CHASE,
	ATTACK,
}

@export var display_name: String = "Hostile"
@export var max_health: float = 75.0
@export var soulite_reward: int = 40
@export var move_speed: float = 3.0
@export var attack_damage: float = 15.0
@export var aggro_range: float = 15.0
@export var attack_range: float = 2.0
@export var contact_damage_range: float = 1.25
@export var contact_damage_cooldown: float = 1.2
@export var attack_windup: float = 0.8
@export var attack_dash_speed: float = 8.0
@export var floor_check_ahead_distance: float = 0.8
@export var floor_check_drop: float = 2.0
@export var damage_flash_duration: float = 0.15


# --- DATA & REFERENCES ---

var current_health: float = 75.0
var is_dead: bool = false

var _state: State = State.IDLE
var _spawn_position: Vector3 = Vector3.ZERO
var _attack_timer: float = 0.0
var _contact_damage_timer: float = 0.0
var _is_winding_up: bool = false
var _attack_direction: Vector3 = Vector3.ZERO
var _player: Player = null
var _body_material: StandardMaterial3D = null
var _default_albedo: Color = Color(0.35, 0.15, 0.55, 1.0)
var _default_emission: Color = Color(0.25, 0.1, 0.4, 1.0)
var _default_emission_energy: float = 0.35
var _damage_flash_tween: Tween = null

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	add_to_group(BonfireRespawn.GROUP_NAME)
	_spawn_position = global_position
	current_health = max_health
	_setup_body_material()


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if _is_ai_paused():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	_refresh_player_ref()

	if _contact_damage_timer > 0.0:
		_contact_damage_timer = maxf(_contact_damage_timer - delta, 0.0)

	match _state:
		State.IDLE:
			_process_idle()
		State.CHASE:
			_process_chase(delta)
		State.ATTACK:
			_process_attack(delta)

	move_and_slide()
	_try_contact_damage()


# --- PUBLIC METHODS ---

func take_damage(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return

	current_health = clampf(current_health - amount, 0.0, max_health)
	_play_damage_flash()

	if current_health <= 0.0:
		_die()


func respawn() -> void:
	is_dead = false
	current_health = max_health
	_state = State.IDLE
	_attack_timer = 0.0
	_contact_damage_timer = 0.0
	_is_winding_up = false
	_attack_direction = Vector3.ZERO
	global_position = _spawn_position
	velocity = Vector3.ZERO
	_reset_body_material()

	if collision_shape:
		collision_shape.disabled = false

	if mesh_instance:
		mesh_instance.visible = true

	respawned.emit()


# --- PRIVATE METHODS ---

func _setup_body_material() -> void:
	if not mesh_instance:
		return

	var source_material: Material = mesh_instance.get_active_material(0)
	if source_material is StandardMaterial3D:
		_body_material = source_material.duplicate() as StandardMaterial3D
	else:
		_body_material = StandardMaterial3D.new()

	mesh_instance.set_surface_override_material(0, _body_material)
	_default_albedo = _body_material.albedo_color
	_default_emission = _body_material.emission
	_default_emission_energy = _body_material.emission_energy_multiplier


func _reset_body_material() -> void:
	if _damage_flash_tween and _damage_flash_tween.is_valid():
		_damage_flash_tween.kill()

	_damage_flash_tween = null

	if not _body_material:
		return

	_body_material.albedo_color = _default_albedo
	_body_material.emission = _default_emission
	_body_material.emission_energy_multiplier = _default_emission_energy


func _play_damage_flash() -> void:
	if not _body_material:
		return

	if _damage_flash_tween and _damage_flash_tween.is_valid():
		_damage_flash_tween.kill()

	_body_material.albedo_color = Color(1.0, 0.85, 0.85, 1.0)
	_body_material.emission = Color(1.0, 0.35, 0.35, 1.0)
	_body_material.emission_energy_multiplier = 1.0

	_damage_flash_tween = create_tween()
	_damage_flash_tween.tween_property(_body_material, "albedo_color", _default_albedo, damage_flash_duration)
	_damage_flash_tween.parallel().tween_property(_body_material, "emission", _default_emission, damage_flash_duration)
	_damage_flash_tween.parallel().tween_property(
		_body_material,
		"emission_energy_multiplier",
		_default_emission_energy,
		damage_flash_duration
	)


func _process_idle() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

	if _is_player_within_aggro_range():
		_state = State.CHASE


func _process_chase(_delta: float) -> void:
	if _is_player_in_attack_range():
		_begin_attack()
		return

	if not _is_player_within_aggro_range():
		_state = State.IDLE
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var direction: Vector3 = _get_horizontal_direction_to_player()

	if not _has_floor_ahead(direction):
		velocity.x = 0.0
		velocity.z = 0.0
		_face_direction(direction)
		return

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	_face_direction(direction)


func _process_attack(delta: float) -> void:
	_attack_timer -= delta

	if _is_winding_up:
		if _has_floor_ahead(_attack_direction):
			velocity.x = _attack_direction.x * attack_dash_speed
			velocity.z = _attack_direction.z * attack_dash_speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0

		_face_direction(_attack_direction)

		if _attack_timer > 0.0:
			return

		_is_winding_up = false
		_attack_timer = contact_damage_cooldown
		velocity.x = 0.0
		velocity.z = 0.0
		return

	velocity.x = 0.0
	velocity.z = 0.0

	if _attack_timer > 0.0:
		return

	if _is_player_in_attack_range():
		_begin_attack()
	else:
		_state = State.CHASE


func _begin_attack() -> void:
	_state = State.ATTACK
	_is_winding_up = true
	_attack_timer = attack_windup
	_attack_direction = _get_horizontal_direction_to_player()

	if _attack_direction.length_squared() <= 0.001:
		_attack_direction = -global_transform.basis.z
		_attack_direction.y = 0.0
		_attack_direction = _attack_direction.normalized()


func _try_contact_damage() -> void:
	if not _player or _contact_damage_timer > 0.0:
		return

	if not _is_player_in_contact_range():
		return

	_player.take_damage(attack_damage)
	_contact_damage_timer = contact_damage_cooldown


func _die() -> void:
	if is_dead:
		return

	is_dead = true
	_state = State.IDLE
	velocity = Vector3.ZERO
	_reset_body_material()

	if collision_shape:
		collision_shape.disabled = true

	if mesh_instance:
		mesh_instance.visible = false

	_grant_soulite_reward()
	died.emit(soulite_reward)

	if DebugSettings.ENABLED:
		DebugSettings.log(
			display_name + " defeated. Awarded " + str(soulite_reward) + " Soulite."
		)


func _grant_soulite_reward() -> void:
	if soulite_reward <= 0:
		return

	_refresh_player_ref()

	if not _player:
		_player = get_tree().get_first_node_in_group("player") as Player

	if not _player:
		return

	_player.soulite_manager.add_soulite(soulite_reward)


func _has_floor_ahead(direction: Vector3) -> bool:
	if direction.length_squared() <= 0.001:
		return true

	var normalized_direction: Vector3 = direction.normalized()
	var check_origin: Vector3 = global_position + normalized_direction * floor_check_ahead_distance
	var ray_start: Vector3 = check_origin + Vector3.UP * 0.25
	var ray_end: Vector3 = check_origin + Vector3.DOWN * floor_check_drop

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]

	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return not result.is_empty()


func _refresh_player_ref() -> void:
	if _player and is_instance_valid(_player):
		return

	_player = get_tree().get_first_node_in_group("player") as Player


func _is_ai_paused() -> bool:
	if not _player or not is_instance_valid(_player):
		return false

	return _player.is_gameplay_blocked()


func _is_player_within_aggro_range() -> bool:
	return _horizontal_distance_to_player() <= aggro_range


func _is_player_in_attack_range() -> bool:
	return _horizontal_distance_to_player() <= attack_range


func _is_player_in_contact_range() -> bool:
	return _horizontal_distance_to_player() <= contact_damage_range


func _horizontal_distance_to_player() -> float:
	if not _player:
		return INF

	var offset: Vector3 = _player.global_position - global_position
	offset.y = 0.0
	return offset.length()


func _get_horizontal_direction_to_player() -> Vector3:
	if not _player:
		return Vector3.ZERO

	var direction: Vector3 = _player.global_position - global_position
	direction.y = 0.0

	if direction.length_squared() <= 0.001:
		return Vector3.ZERO

	return direction.normalized()


func _face_direction(direction: Vector3) -> void:
	if direction.length_squared() <= 0.001:
		return

	rotation.y = atan2(direction.x, direction.z)
