extends CanvasLayer
class_name HUDLayer

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

@onready var health_bar: ProgressBar = $HUDControl/TopCenterContainer/TopCenterLayout/HealthBar
@onready var state_debug_label: Label = $HUDControl/TopCenterContainer/TopCenterLayout/StateDebugLabel
@onready var over_rad_bar: ProgressBar = $HUDControl/BottomLeftContainer/TacticalLayout/OverRadBar
@onready var ambient_rad_bar: ProgressBar = $HUDControl/BottomLeftContainer/TacticalLayout/AmbientRadBar


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	var player_node: Player = get_parent() as Player
	if player_node:
		player_node.health_changed.connect(_on_health_changed)

		var sm: StateMachine = player_node.get_node_or_null("StateMachine")
		if sm:
			sm.state_changed.connect(_on_state_changed)
		else:
			push_error("HUDLayer: Failed to find StateMachine node on Player parent.")

		var tarc: TarcManager = player_node.get_node_or_null("TarcManager")
		if tarc:
			_connect_tarc_signals(tarc)
		else:
			push_error("HUDLayer: Failed to find TarcManager node on Player parent.")
	else:
		push_error("HUDLayer: HUD is missing a valid Player parent node context.")


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---


# --- PRIVATE METHODS ---

func _on_health_changed(current: float, max_val: float) -> void:
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = current


func _on_state_changed(new_state_name: String) -> void:
	if state_debug_label:
		state_debug_label.text = "STATE: " + new_state_name


func _connect_tarc_signals(tarc: TarcManager) -> void:
	tarc.over_rad_changed.connect(_on_over_rad_changed)
	tarc.ambient_rad_changed.connect(_on_ambient_rad_changed)


func _on_over_rad_changed(new_value: float) -> void:
	if over_rad_bar:
		over_rad_bar.value = new_value


func _on_ambient_rad_changed(current: float, max_val: float) -> void:
	if ambient_rad_bar:
		ambient_rad_bar.max_value = max_val
		ambient_rad_bar.value = current
