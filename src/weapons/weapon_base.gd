extends Node3D
class_name WeaponBase

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var fire_animation_name: String = "sidearm_fire"
@export var idle_animation_name: String = "sidearm_idle"


# --- DATA & REFERENCES ---

var _weapon_data: WeaponData
var _animation_player: AnimationPlayer
var _idle_active: bool = false


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	_animation_player = _find_animation_player(self)

	if not _animation_player:
		push_warning("WeaponBase: No AnimationPlayer found on weapon.")
		return

	if _animation_player.has_animation(idle_animation_name):
		var idle_animation: Animation = _animation_player.get_animation(idle_animation_name)
		idle_animation.loop_mode = Animation.LOOP_LINEAR

	_animation_player.animation_finished.connect(_on_animation_finished)


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func configure(data: WeaponData) -> void:
	_weapon_data = data

	if not data:
		return

	fire_animation_name = data.fire_animation_name
	idle_animation_name = data.idle_animation_name


func get_weapon_data() -> WeaponData:
	return _weapon_data


func play_fire() -> bool:
	if not _animation_player:
		return false

	if not _animation_player.has_animation(fire_animation_name):
		push_warning("WeaponBase: Missing animation '" + fire_animation_name + "'.")
		return false

	if _is_fire_animation_playing():
		return false

	_animation_player.play(fire_animation_name)
	return true


func get_fire_cooldown_duration() -> float:
	if not _animation_player:
		return _get_fallback_fire_rate()

	if not _animation_player.has_animation(fire_animation_name):
		return _get_fallback_fire_rate()

	var animation_length: float = _animation_player.get_animation(fire_animation_name).length
	var multiplier: float = 1.0

	if _weapon_data:
		multiplier = _weapon_data.fire_cooldown_multiplier

	return animation_length * multiplier


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

func _get_fallback_fire_rate() -> float:
	if _weapon_data:
		return _weapon_data.fire_rate

	return 0.5


func _try_play_idle() -> void:
	if not _idle_active or not _animation_player:
		return

	if _is_fire_animation_playing():
		return

	if not _animation_player.has_animation(idle_animation_name):
		push_warning("WeaponBase: Missing animation '" + idle_animation_name + "'.")
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
