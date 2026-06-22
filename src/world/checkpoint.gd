extends Interactable
class_name Checkpoint

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var checkpoint_name: String = "Checkpoint"
@export var spawn_offset: Vector3 = Vector3(0.0, 1.2, 1.5)


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	interaction_prompt = "Hold R to rest at " + checkpoint_name


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func interact(target_player: Player) -> void:
	if not target_player:
		return

	CheckpointManager.register_bonfire(self)
	BonfireRespawn.respawn_all(get_tree())
	target_player.open_checkpoint_menu(self)


func get_spawn_position() -> Vector3:
	return global_position + spawn_offset


# --- PRIVATE METHODS ---
