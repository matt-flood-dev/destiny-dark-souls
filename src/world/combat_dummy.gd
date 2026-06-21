extends StaticBody3D
class_name CombatDummy

# --- SIGNALS ---

signal died(soulite_reward: int)
signal respawned()


# --- CONFIGURATION & EXPORTS ---

@export var display_name: String = "Training Dummy"
@export var max_health: float = 50.0
@export var soulite_reward: int = 25


# --- DATA & REFERENCES ---

var current_health: float = 50.0
var is_dead: bool = false

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	add_to_group("combat_dummy")
	current_health = max_health


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func take_damage(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return

	current_health = clampf(current_health - amount, 0.0, max_health)

	if current_health <= 0.0:
		_die()


func respawn() -> void:
	is_dead = false
	current_health = max_health

	if collision_shape:
		collision_shape.disabled = false

	if mesh_instance:
		mesh_instance.visible = true

	respawned.emit()


static func respawn_all(scene_tree: SceneTree) -> void:
	for node in scene_tree.get_nodes_in_group("combat_dummy"):
		var dummy: CombatDummy = node as CombatDummy
		if dummy:
			dummy.respawn()


# --- PRIVATE METHODS ---

func _die() -> void:
	if is_dead:
		return

	is_dead = true

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

	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		return

	player.soulite_manager.add_soulite(soulite_reward)
