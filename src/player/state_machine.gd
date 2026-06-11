extends Node
class_name StateMachine

# --- SIGNALS ---

signal state_changed(new_state_name: String)


# --- CONFIGURATION & EXPORTS ---

@export var initial_state: PlayerState


# --- DATA & REFERENCES ---

var current_state: PlayerState
var previous_state: PlayerState
var states: Dictionary = {}


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	await get_parent().ready

	for child in get_children():
		if child is PlayerState:
			states[child.name] = child
			child.player = get_parent() as Player
			child.state_machine = self

	if initial_state:
		current_state = initial_state
		current_state.enter()

		await get_tree().process_frame
		state_changed.emit(current_state.name)


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
	var target_state: PlayerState = states.get(new_state_name)

	if not target_state:
		push_error("StateMachine: State '" + new_state_name + "' does not exist.")
		return

	if current_state == target_state:
		return

	if current_state:
		current_state.exit()
		previous_state = current_state

	current_state = target_state
	current_state.enter()

	state_changed.emit(current_state.name)

# --- PRIVATE METHODS --- 
