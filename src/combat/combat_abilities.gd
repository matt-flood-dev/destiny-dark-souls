class_name CombatAbilities
extends RefCounted

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

const MELEE_DAMAGE: float = 35.0
const MELEE_FORWARD_OFFSET: float = 1.1
const MELEE_HEIGHT_OFFSET: float = 1.0
const MELEE_RADIUS: float = 1.15

const GRENADE_DAMAGE: float = 45.0
const GRENADE_RADIUS: float = 3.5
const GRENADE_MAX_RANGE: float = 30.0


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

static func perform_melee(player: Player) -> Dictionary:
	var result: Dictionary = {
		"hit": false,
		"targets_hit": 0,
		"target_name": "",
	}

	if not player:
		return result

	var world: World3D = player.get_world_3d()
	if not world:
		return result

	var attack_forward: Vector3 = -player.camera.global_transform.basis.z
	attack_forward.y = 0.0

	if attack_forward.is_zero_approx():
		return result

	attack_forward = attack_forward.normalized()

	var attack_center: Vector3 = (
		player.global_position
		+ Vector3.UP * MELEE_HEIGHT_OFFSET
		+ attack_forward * MELEE_FORWARD_OFFSET
	)

	var sphere_shape: SphereShape3D = SphereShape3D.new()
	sphere_shape.radius = MELEE_RADIUS

	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere_shape
	query.transform = Transform3D(Basis.IDENTITY, attack_center)
	query.collide_with_areas = false
	query.exclude = [player.get_rid()]

	var space_state: PhysicsDirectSpaceState3D = world.direct_space_state
	var hits: Array[Dictionary] = space_state.intersect_shape(query)

	for hit in hits:
		var target = hit["collider"]
		if not target or not target.has_method("take_damage"):
			continue

		target.take_damage(MELEE_DAMAGE)
		result["hit"] = true
		result["targets_hit"] += 1

		if result["target_name"].is_empty():
			result["target_name"] = str(target.name)

	return result


static func perform_grenade(player: Player, aim_raycast: RayCast3D) -> Dictionary:
	var result: Dictionary = {
		"hit": false,
		"targets_hit": 0,
		"target_name": "",
	}

	if not player or not aim_raycast:
		return result

	var world: World3D = player.get_world_3d()
	if not world:
		return result

	var impact_point: Vector3 = _get_grenade_impact_point(player, aim_raycast)

	var sphere_shape: SphereShape3D = SphereShape3D.new()
	sphere_shape.radius = GRENADE_RADIUS

	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere_shape
	query.transform = Transform3D(Basis.IDENTITY, impact_point)
	query.collide_with_areas = false
	query.exclude = [player.get_rid()]

	var space_state: PhysicsDirectSpaceState3D = world.direct_space_state
	var hits: Array[Dictionary] = space_state.intersect_shape(query)

	for hit in hits:
		var target = hit["collider"]
		if not target or not target.has_method("take_damage"):
			continue

		target.take_damage(GRENADE_DAMAGE)
		result["hit"] = true
		result["targets_hit"] += 1

		if result["target_name"].is_empty():
			result["target_name"] = str(target.name)

	return result


# --- PRIVATE METHODS ---

static func _get_grenade_impact_point(player: Player, aim_raycast: RayCast3D) -> Vector3:
	aim_raycast.force_raycast_update()

	if aim_raycast.is_colliding():
		return aim_raycast.get_collision_point()

	var ray_origin: Vector3 = aim_raycast.global_position
	var ray_direction: Vector3 = aim_raycast.global_transform.basis * aim_raycast.target_position

	if ray_direction.length_squared() <= 0.0001:
		ray_direction = -player.camera.global_transform.basis.z

	ray_direction = ray_direction.normalized()
	return ray_origin + ray_direction * GRENADE_MAX_RANGE
