extends Node3D
class_name SidearmWeapon

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var fire_animation_name: String = "sidearm_fire"
@export var idle_animation_name: String = "sidearm_idle"


# --- DATA & REFERENCES ---

var _animation_player: AnimationPlayer
var _idle_active: bool = false


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	_animation_player = _find_animation_player(self)

	if not _animation_player:
		push_warning("SidearmWeapon: No AnimationPlayer found on sidearm.")
		return

	if _animation_player.has_animation(idle_animation_name):
		var idle_animation: Animation = _animation_player.get_animation(idle_animation_name)
		idle_animation.loop_mode = Animation.LOOP_LINEAR

	_animation_player.animation_finished.connect(_on_animation_finished)


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


func play_idle() -> void:
	_idle_active = true
	_try_play_idle()


func stop_idle() -> void:
	_idle_active = false

	if not _animation_player:
		return

	if _animation_player.is_playing() and _animation_player.current_animation == idle_animation_name:
		_animation_player.stop()


# --- PRIVATE METHODS ---

func _try_play_idle() -> void:
	if not _idle_active or not _animation_player:
		return

	if _is_fire_animation_playing():
		return

	if not _animation_player.has_animation(idle_animation_name):
		push_warning("SidearmWeapon: Missing animation '" + idle_animation_name + "'.")
		return

	if _animation_player.is_playing() and _animation_player.current_animation == idle_animation_name:
		return

	_animation_player.play(idle_animation_name)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == fire_animation_name:
		_try_play_idle()


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
