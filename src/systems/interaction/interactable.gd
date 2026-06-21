extends Node3D
class_name Interactable

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var interaction_prompt: String = "Hold R to interact"


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func can_interact(_player: Player) -> bool:
	return true


func interact(_player: Player) -> void:
	pass


# --- PRIVATE METHODS ---
