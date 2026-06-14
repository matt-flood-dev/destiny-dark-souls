extends CanvasLayer
class_name HUDLayer

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

@onready var health_bar: ProgressBar = $HUDControl/VitalsContainer/VitalsLayout/HealthBar
@onready var over_rad_bar: ProgressBar = $HUDControl/TacticalContainer/TacticalLayout/RadBarRow/OverRadBar
@onready var ambient_rad_bar: ProgressBar = $HUDControl/TacticalContainer/TacticalLayout/RadBarRow/AmbientRadBar
@onready var state_debug_label: Label = $HUDControl/VitalsContainer/VitalsLayout/StateDebugLabel
@onready var weapon_fired_debug_label: Label = $HUDControl/VitalsContainer/VitalsLayout/WeaponFiredDebugLabel
@onready var weapon_hit_debug_label: Label = $HUDControl/VitalsContainer/VitalsLayout/WeaponHitDebugLabel
@onready var ammo_label: Label = $HUDControl/TacticalContainer/TacticalLayout/LoadoutRow/WeaponSlots/WeaponSlot1/AmmoLabel


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	var player_node: Player = get_parent() as Player
	if player_node:
		player_node.health_changed.connect(_on_health_changed)
		player_node.ammo_changed.connect(_on_ammo_changed)
		player_node.weapon_fired.connect(_on_weapon_fired)
		player_node.weapon_hit.connect(_on_weapon_hit)

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


func _on_ammo_changed(current: int, max_val: int) -> void:
	if ammo_label:
		ammo_label.text = str(current) + " / " + str(max_val)


func _on_weapon_fired(info_text: String) -> void:
	if weapon_fired_debug_label:
		weapon_fired_debug_label.text = info_text


func _on_weapon_hit(info_text: String) -> void:
	if weapon_hit_debug_label:
		weapon_hit_debug_label.text = info_text


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
