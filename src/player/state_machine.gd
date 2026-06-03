extends Node
class_name StateMachine

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var initial_state: PlayerState


# --- DATA & REFERENCES ---

var current_state: PlayerState
var previous_state: PlayerState
var states: Dictionary = {}


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	for child in get_children():
		if child is PlayerState:
			states[child.name.to_lower()] = child
			child.player = get_parent() as Player
			child.state_machine = self

	if initial_state:
		current_state = initial_state
		current_state.enter()


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


# --- PUBLIC METHODS ---

func change_state(new_state_name: String) -> void:
	var target_state: PlayerState = states.get(new_state_name.to_lower())

	if not target_state:
		push_error("StateMachine: State '" + new_state_name + "' does not exist.")
		return

	if current_state:
		current_state.exit()
		previous_state = current_state

	current_state = target_state
	current_state.enter()


# --- PRIVATE METHODS --- 
