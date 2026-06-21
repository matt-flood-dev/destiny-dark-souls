extends Interactable
class_name Checkpoint

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var checkpoint_name: String = "Checkpoint"


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

	target_player.open_checkpoint_menu(self)


# --- PRIVATE METHODS ---
