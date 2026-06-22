extends Node
class_name SouliteManager

# --- SIGNALS ---

signal soulite_changed(current: int)


# --- CONFIGURATION & EXPORTS ---

@export var starting_soulite: int = 100


# --- DATA & REFERENCES ---

var current_soulite: int = 0


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	current_soulite = SouliteStainManager.get_starting_soulite_after_respawn(starting_soulite)
	soulite_changed.emit(current_soulite)

# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func add_soulite(amount: int) -> void:
	if amount <= 0:
		return

	current_soulite += amount
	soulite_changed.emit(current_soulite)


func spend_soulite(amount: int) -> bool:
	if amount <= 0:
		return true

	if current_soulite < amount:
		return false

	current_soulite -= amount
	soulite_changed.emit(current_soulite)
	return true


func can_afford(amount: int) -> bool:
	return current_soulite >= amount


# --- PRIVATE METHODS ---
