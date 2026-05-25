extends Node
class_name PlayerState

# --- DATA TRACKING & SYSTEM REFS ---
var player: Player
var state_machine: StateMachine


# --- ENGINE RUNTIME LOOPS ---
func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	_handle_look_rotation()


func physics_update(_delta: float) -> void:
	pass


# --- LOOK ROTATION LOGIC ---
func _handle_look_rotation() -> void:
	if player.mouse_input != Vector2.ZERO:
		player.rotate_y(-player.mouse_input.x * player.mouse_sensitivity)
		player.camera.rotate_x(-player.mouse_input.y * player.mouse_sensitivity)
		player.camera.rotation.x = clamp(player.camera.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))
		player.mouse_input = Vector2.ZERO
