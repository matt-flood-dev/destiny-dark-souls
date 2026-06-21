extends Node
class_name InteractionManager

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

const INTERACT_HOLD_TIME: float = 0.4


# --- DATA & REFERENCES ---

var player: Player
var interact_raycast: RayCast3D

var _is_holding_interact: bool = false
var _hold_timer: float = 0.0
var _interact_triggered: bool = false


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func process_hold(delta: float) -> void:
	if not _is_holding_interact or _interact_triggered:
		return

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	_hold_timer += delta

	if _hold_timer < INTERACT_HOLD_TIME:
		return

	var interactable: Interactable = _get_focused_interactable()
	if not interactable or not interactable.can_interact(player):
		return

	interactable.interact(player)
	_interact_triggered = true


# --- PUBLIC METHODS ---

func setup(owner_player: Player, raycast: RayCast3D) -> void:
	player = owner_player
	interact_raycast = raycast


func begin_interact_hold() -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	_is_holding_interact = true
	_hold_timer = 0.0
	_interact_triggered = false


func complete_interact_hold() -> bool:
	var consumed_input: bool = _interact_triggered

	_is_holding_interact = false
	_hold_timer = 0.0
	_interact_triggered = false

	return consumed_input


func get_focused_interactable() -> Interactable:
	return _get_focused_interactable()


# --- PRIVATE METHODS ---

func _get_focused_interactable() -> Interactable:
	if not interact_raycast:
		return null

	interact_raycast.force_raycast_update()

	if not interact_raycast.is_colliding():
		return null

	var collider: Object = interact_raycast.get_collider()
	var node: Node = collider as Node

	while node:
		if node is Interactable:
			return node as Interactable

		node = node.get_parent()

	return null
