extends Interactable
class_name SouliteStain

# --- SIGNALS ---

signal collected(amount: int)


# --- CONFIGURATION & EXPORTS ---


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
	global_position = world_position
	_soulite_amount = soulite_amount
	_update_interaction_prompt()


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

func _update_interaction_prompt() -> void:
	if _soulite_amount > 0:
		interaction_prompt = "Hold R to recover " + str(_soulite_amount) + " Soulite"
	else:
		interaction_prompt = "Hold R to recover Soulite"
