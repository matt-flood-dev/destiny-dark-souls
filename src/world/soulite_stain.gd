extends Interactable
class_name SouliteStain

# --- SIGNALS ---

signal collected(amount: int)


# --- CONFIGURATION & EXPORTS ---

const FLOOR_RAYCAST_HEIGHT: float = 2.0
const FLOOR_RAYCAST_DEPTH: float = 50.0
const FLOOR_SURFACE_OFFSET: float = 0.06
const FLOOR_NORMAL_MIN_DOT: float = 0.7
const FLOOR_RAYCAST_MAX_HITS: int = 8


# --- DATA & REFERENCES ---

var _soulite_amount: int = 0

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	if _soulite_amount <= 0:
		_soulite_amount = SouliteStainManager.stain_soulite

	_update_interaction_prompt()


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func setup(world_position: Vector3, soulite_amount: int) -> void:
	_soulite_amount = soulite_amount
	_update_interaction_prompt()
	_place_at_world_position(world_position)


func can_interact(_player: Player) -> bool:
	return SouliteStainManager.has_active_stain and SouliteStainManager.stain_soulite > 0


func interact(player: Player) -> void:
	if not player or not can_interact(player):
		return

	var recovered_soulite: int = SouliteStainManager.consume_stain()
	if recovered_soulite <= 0:
		queue_free()
		return

	player.soulite_manager.add_soulite(recovered_soulite)
	collected.emit(recovered_soulite)
	queue_free()


# --- PRIVATE METHODS ---

func _place_at_world_position(world_position: Vector3) -> void:
	global_position = _get_floor_position(world_position)


func _get_floor_position(world_position: Vector3) -> Vector3:
	var world: World3D = get_world_3d()
	if not world:
		return _get_fallback_floor_position(world_position)

	var space_state: PhysicsDirectSpaceState3D = world.direct_space_state
	var ray_start: Vector3 = world_position + Vector3.UP * FLOOR_RAYCAST_HEIGHT
	var ray_end: Vector3 = world_position + Vector3.DOWN * FLOOR_RAYCAST_DEPTH
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collide_with_areas = false

	var excluded_rids: Array[RID] = []

	for _hit_index in FLOOR_RAYCAST_MAX_HITS:
		query.exclude = excluded_rids

		var result: Dictionary = space_state.intersect_ray(query)
		if result.is_empty():
			break

		var hit_normal: Vector3 = result["normal"] as Vector3
		if hit_normal.dot(Vector3.UP) >= FLOOR_NORMAL_MIN_DOT:
			var floor_position: Vector3 = result["position"] as Vector3
			floor_position.y += FLOOR_SURFACE_OFFSET
			return floor_position

		excluded_rids.append(result["rid"] as RID)

	return _get_fallback_floor_position(world_position)


func _get_fallback_floor_position(world_position: Vector3) -> Vector3:
	var floor_position: Vector3 = world_position
	floor_position.y -= 1.0
	return floor_position


func _update_interaction_prompt() -> void:
	if _soulite_amount > 0:
		interaction_prompt = "Hold R to recover " + str(_soulite_amount) + " Soulite"
	else:
		interaction_prompt = "Hold R to recover Soulite"
