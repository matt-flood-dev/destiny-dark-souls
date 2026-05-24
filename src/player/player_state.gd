extends Node
class_name PlayerState

# =============================================================================
# BASE CLASS: PLAYER STATE
# =============================================================================
var player: Player
var state_machine: StateMachine


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
