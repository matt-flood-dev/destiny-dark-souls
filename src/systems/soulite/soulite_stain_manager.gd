extends Node

# --- SIGNALS ---

signal stain_changed()


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

var has_active_stain: bool = false
var stain_position: Vector3 = Vector3.ZERO
var stain_soulite: int = 0

var _respawn_with_zero_soulite: bool = false


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func register_player_death(death_position: Vector3, carried_soulite: int) -> void:
	_respawn_with_zero_soulite = true

	if carried_soulite <= 0:
		clear_stain()

		if DebugSettings.ENABLED:
			DebugSettings.log("SouliteStainManager: Player died with no Soulite. Active stain lost.")

		return

	stain_position = death_position
	stain_soulite = carried_soulite
	has_active_stain = true
	stain_changed.emit()

	if DebugSettings.ENABLED:
		DebugSettings.log(
			"SouliteStainManager: Dropped "
			+ str(stain_soulite)
			+ " Soulite at "
			+ str(stain_position)
		)


func consume_stain() -> int:
	if not has_active_stain or stain_soulite <= 0:
		return 0

	var recovered_soulite: int = stain_soulite
	clear_stain()

	if DebugSettings.ENABLED:
		DebugSettings.log("SouliteStainManager: Recovered " + str(recovered_soulite) + " Soulite.")

	return recovered_soulite


func clear_stain() -> void:
	if not has_active_stain and stain_soulite <= 0:
		return

	has_active_stain = false
	stain_soulite = 0
	stain_changed.emit()


func get_starting_soulite_after_respawn(default_starting: int) -> int:
	if not _respawn_with_zero_soulite:
		return maxi(default_starting, 0)

	_respawn_with_zero_soulite = false
	return 0


# --- PRIVATE METHODS ---
