extends Node3D

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

const SOULITE_STAIN_SCENE: PackedScene = preload("res://src/world/soulite_stain.tscn")


# --- DATA & REFERENCES ---

var _active_stain: SouliteStain = null


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	SouliteStainManager.stain_changed.connect(_on_stain_changed)
	_spawn_active_stain()


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---


# --- PRIVATE METHODS ---

func _spawn_active_stain() -> void:
	_clear_active_stain()

	if not SouliteStainManager.has_active_stain:
		return

	if SouliteStainManager.stain_soulite <= 0:
		return

	var stain: SouliteStain = SOULITE_STAIN_SCENE.instantiate() as SouliteStain
	if not stain:
		push_error("World: Failed to instantiate SouliteStain.")
		return

	add_child(stain)
	stain.setup(SouliteStainManager.stain_position, SouliteStainManager.stain_soulite)
	_active_stain = stain


func _clear_active_stain() -> void:
	if _active_stain and is_instance_valid(_active_stain):
		_active_stain.queue_free()

	_active_stain = null


func _on_stain_changed() -> void:
	if SouliteStainManager.has_active_stain:
		_spawn_active_stain()
	else:
		_active_stain = null
