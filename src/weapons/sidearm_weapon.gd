extends Node3D
class_name SidearmWeapon

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var fire_animation_name: String = "sidearm_fire"


# --- DATA & REFERENCES ---

var _animation_player: AnimationPlayer


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	_animation_player = _find_animation_player(self)

	if not _animation_player:
		push_warning("SidearmWeapon: No AnimationPlayer found on sidearm.")


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func play_fire() -> bool:
	if not _animation_player:
		return false

	if not _animation_player.has_animation(fire_animation_name):
		push_warning("SidearmWeapon: Missing animation '" + fire_animation_name + "'.")
		return false

	if _is_fire_animation_playing():
		return false

	_animation_player.play(fire_animation_name)
	return true


func get_fire_cooldown_duration() -> float:
	if not _animation_player:
		return 0.0

	if not _animation_player.has_animation(fire_animation_name):
		return 0.0

	return _animation_player.get_animation(fire_animation_name).length


# --- PRIVATE METHODS ---

func _is_fire_animation_playing() -> bool:
	return _animation_player.is_playing() and _animation_player.current_animation == fire_animation_name

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer

	for child in node.get_children():
		var found: AnimationPlayer = _find_animation_player(child)
		if found:
			return found

	return null
