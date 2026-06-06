extends Node
class_name PlayerState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

const DOUBLE_TAP_TIME: float = 0.25
const HOLD_TIME_THRESHOLD: float = 0.20


# --- DATA & REFERENCES ---

var player: Player
var state_machine: StateMachine

static var can_double_jump: bool = false
var double_tap_timer: float = 0.0
var action_hold_time: float = 0.0
var is_holding_action: bool = false


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func apply_gravity(delta: float) -> void:
	if not player:
		return

	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta
	else:
		player.velocity.y = 0.0


# --- PRIVATE METHODS ---
