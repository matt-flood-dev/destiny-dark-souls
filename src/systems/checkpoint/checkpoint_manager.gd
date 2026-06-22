extends Node

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

const DEATH_SCREEN_DURATION: float = 2.5


# --- DATA & REFERENCES ---

var has_last_bonfire: bool = false
var last_bonfire_name: String = ""
var last_bonfire_position: Vector3 = Vector3.ZERO

var _pending_death_respawn: bool = false
var _show_death_screen: bool = false
var _death_screen_message: String = ""


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func register_bonfire(checkpoint: Checkpoint) -> void:
	if not checkpoint:
		return

	has_last_bonfire = true
	last_bonfire_name = checkpoint.checkpoint_name
	last_bonfire_position = checkpoint.get_spawn_position()

	if DebugSettings.ENABLED:
		DebugSettings.log(
			"CheckpointManager: Rested at "
			+ last_bonfire_name
			+ " ("
			+ str(last_bonfire_position)
			+ ")"
		)


func prepare_death_respawn(lost_soulite: int) -> void:
	_pending_death_respawn = true
	_show_death_screen = true
	_death_screen_message = _build_death_screen_message(lost_soulite)


func consume_pending_death_respawn() -> bool:
	if not _pending_death_respawn:
		return false

	_pending_death_respawn = false
	return has_last_bonfire


func get_respawn_position() -> Vector3:
	if has_last_bonfire:
		return last_bonfire_position

	return Vector3.ZERO


func should_show_death_screen() -> bool:
	return _show_death_screen


func consume_death_screen_message() -> String:
	_show_death_screen = false
	return _death_screen_message


func get_death_screen_duration() -> float:
	return DEATH_SCREEN_DURATION


# --- PRIVATE METHODS ---

func _build_death_screen_message(lost_soulite: int) -> String:
	var message_lines: PackedStringArray = PackedStringArray()

	if lost_soulite > 0:
		message_lines.append("Lost " + str(lost_soulite) + " Soulite")

	if has_last_bonfire:
		message_lines.append("Returned to " + last_bonfire_name)
	else:
		message_lines.append("Returned to last location")

	return "\n".join(message_lines)
