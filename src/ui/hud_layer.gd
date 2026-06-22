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
@onready var weapon_slot_1: PanelContainer = $HUDControl/TacticalContainer/TacticalLayout/LoadoutRow/WeaponSlots/WeaponSlot1
@onready var weapon_slot_2: PanelContainer = $HUDControl/TacticalContainer/TacticalLayout/LoadoutRow/WeaponSlots/WeaponSlot2
@onready var weapon_slot_3: PanelContainer = $HUDControl/TacticalContainer/TacticalLayout/LoadoutRow/WeaponSlots/WeaponSlot3
@onready var soulite_label: Label = $HUDControl/SouliteContainer/SouliteLabel
@onready var checkpoint_menu: CheckpointMenu = $HUDControl/CheckpointMenu
@onready var death_overlay: ColorRect = $HUDControl/DeathOverlay
@onready var death_title: Label = $HUDControl/DeathOverlay/DeathVBox/DeathTitle
@onready var death_subtitle: Label = $HUDControl/DeathOverlay/DeathVBox/DeathSubtitle
@onready var grenade_slot: AbilitySlot = $HUDControl/TacticalContainer/TacticalLayout/LoadoutRow/AbilitySlots/GrenadeSlot
@onready var melee_slot: AbilitySlot = $HUDControl/TacticalContainer/TacticalLayout/LoadoutRow/AbilitySlots/MeleeSlot

var _tarc: TarcManager


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

		var soulite: SouliteManager = player_node.get_node_or_null("SouliteManager")
		if soulite:
			soulite.soulite_changed.connect(_on_soulite_changed)
			_on_soulite_changed(soulite.current_soulite)
		else:
			push_error("HUDLayer: Failed to find SouliteManager node on Player parent.")
	else:
		push_error("HUDLayer: HUD is missing a valid Player parent node context.")

	_apply_debug_hud()
	sync_weapon_slots(0)


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func _process(_delta: float) -> void:
	if not _tarc:
		return

	_sync_ability_slot(grenade_slot, _tarc.grenade_cooldown_timer, TarcManager.GRENADE_COOLDOWN_MAX)
	_sync_ability_slot(melee_slot, _tarc.melee_cooldown_timer, TarcManager.MELEE_COOLDOWN_MAX)


# --- PUBLIC METHODS ---

func sync_weapon_slots(active_slot_index: int, loadout_manager: LoadoutManager = null) -> void:
	_apply_weapon_slot_highlight(weapon_slot_1, active_slot_index == 0, loadout_manager, 0)
	_apply_weapon_slot_highlight(weapon_slot_2, active_slot_index == 1, loadout_manager, 1)
	_apply_weapon_slot_highlight(weapon_slot_3, active_slot_index == 2, loadout_manager, 2)


func show_death_screen(title: String, subtitle: String) -> void:
	if death_title:
		death_title.text = title

	if death_subtitle:
		death_subtitle.text = subtitle

	if death_overlay:
		death_overlay.visible = true


func hide_death_screen() -> void:
	if death_overlay:
		death_overlay.visible = false

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func is_death_screen_visible() -> bool:
	return death_overlay != null and death_overlay.visible


# --- PRIVATE METHODS ---

func _on_health_changed(current: float, max_val: float) -> void:
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = current


func _on_state_changed(new_state_name: String) -> void:
	if not DebugSettings.ENABLED or not state_debug_label:
		return

	state_debug_label.text = "STATE: " + new_state_name


func _on_ammo_changed(current: int, max_val: int) -> void:
	if ammo_label:
		ammo_label.text = str(current) + " / " + str(max_val)


func _on_soulite_changed(current: int) -> void:
	if soulite_label:
		soulite_label.text = "Soulite: " + str(current)


func _on_weapon_fired(info_text: String) -> void:
	if not DebugSettings.ENABLED or not weapon_fired_debug_label:
		return

	weapon_fired_debug_label.text = info_text


func _on_weapon_hit(info_text: String) -> void:
	if not DebugSettings.ENABLED or not weapon_hit_debug_label:
		return

	weapon_hit_debug_label.text = info_text


func _connect_tarc_signals(tarc: TarcManager) -> void:
	_tarc = tarc
	tarc.over_rad_changed.connect(_on_over_rad_changed)
	tarc.ambient_rad_changed.connect(_on_ambient_rad_changed)
	_on_over_rad_changed(tarc.current_over_rad)
	_on_ambient_rad_changed(tarc.current_ambient_rad, tarc.max_ambient_rad)


func _on_over_rad_changed(new_value: float) -> void:
	if over_rad_bar:
		over_rad_bar.max_value = TarcManager.OVER_RAD_MAX
		over_rad_bar.value = new_value


func _on_ambient_rad_changed(current: float, max_val: float) -> void:
	if ambient_rad_bar:
		ambient_rad_bar.max_value = max_val
		ambient_rad_bar.value = current


func _sync_ability_slot(slot: AbilitySlot, cooldown_remaining: float, cooldown_max: float) -> void:
	if not slot or cooldown_max <= 0.0:
		return

	slot.set_charge_progress(1.0 - (cooldown_remaining / cooldown_max))


func _apply_debug_hud() -> void:
	var debug_visible: bool = DebugSettings.ENABLED

	if state_debug_label:
		state_debug_label.visible = debug_visible

	if weapon_fired_debug_label:
		weapon_fired_debug_label.visible = debug_visible

	if weapon_hit_debug_label:
		weapon_hit_debug_label.visible = debug_visible


func _apply_weapon_slot_highlight(
	slot: PanelContainer,
	is_active: bool,
	loadout_manager: LoadoutManager,
	slot_index: int
) -> void:
	if not slot:
		return

	var is_filled: bool = loadout_manager != null and loadout_manager.is_slot_filled(slot_index)

	if not is_filled:
		slot.modulate = Color(0.45, 0.45, 0.5, 0.65)
	elif is_active:
		slot.modulate = Color(1.0, 0.92, 0.65, 1.0)
	else:
		slot.modulate = Color(0.72, 0.72, 0.78, 1.0)
