extends PanelContainer
class_name CheckpointMenu

# --- SIGNALS ---

signal closed()


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var soulite_label: Label = $MarginContainer/VBoxContainer/SouliteLabel
@onready var magazine_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/MagazineList
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton

var _player: Player = null


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func open(player: Player, checkpoint: Checkpoint) -> void:
	_player = player
	title_label.text = checkpoint.checkpoint_name
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh_menu()


func close_menu() -> void:
	visible = false

	if _player:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	_player = null
	closed.emit()


func is_open() -> bool:
	return visible


# --- PRIVATE METHODS ---

func _refresh_menu() -> void:
	if not _player:
		return

	soulite_label.text = "Soulite: " + str(_player.soulite_manager.current_soulite)

	for child in magazine_list.get_children():
		magazine_list.remove_child(child)
		child.queue_free()

	var loadout_manager: LoadoutManager = _player.loadout_manager
	var active_configuration: WeaponDefinitions.Configuration = loadout_manager.get_active_configuration()

	for configuration in loadout_manager.get_unlocked_configurations():
		var weapon_data: WeaponData = loadout_manager.get_weapon_data(configuration)
		var magazine_state: MagazineState = loadout_manager.get_magazine_state(configuration)

		if not weapon_data or not magazine_state:
			continue

		for magazine_index in range(magazine_state.get_magazine_count()):
			_add_magazine_row(
				configuration,
				weapon_data,
				magazine_state,
				magazine_index,
				configuration == active_configuration
			)


func _add_magazine_row(
	configuration: WeaponDefinitions.Configuration,
	weapon_data: WeaponData,
	magazine_state: MagazineState,
	magazine_index: int,
	is_active_weapon: bool
) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var info_label: Label = Label.new()
	var magazine_suffix: String = " (in gun)" if is_active_weapon and magazine_index == magazine_state.gun_mag_index else ""
	var current_rounds: int = magazine_state.get_magazine_rounds(magazine_index)
	info_label.text = (
		weapon_data.display_name
		+ " Mag "
		+ str(magazine_index + 1)
		+ magazine_suffix
		+ ": "
		+ str(current_rounds)
		+ " / "
		+ str(magazine_state.get_gun_capacity())
	)
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info_label)

	var missing_rounds: int = magazine_state.get_missing_rounds(magazine_index)
	if missing_rounds <= 0:
		var full_label: Label = Label.new()
		full_label.text = "Full"
		row.add_child(full_label)
		magazine_list.add_child(row)
		return

	var one_round_cost: int = _player.loadout_manager.get_refill_cost(configuration, 1)
	var fill_cost: int = _player.loadout_manager.get_fill_magazine_cost(configuration, magazine_index)

	var add_one_button: Button = Button.new()
	add_one_button.text = "+1 (" + str(one_round_cost) + ")"
	add_one_button.pressed.connect(_on_add_one_round_pressed.bind(configuration, magazine_index))
	row.add_child(add_one_button)

	var fill_button: Button = Button.new()
	fill_button.text = "Fill (" + str(fill_cost) + ")"
	fill_button.pressed.connect(_on_fill_magazine_pressed.bind(configuration, magazine_index))
	row.add_child(fill_button)

	magazine_list.add_child(row)


func _on_add_one_round_pressed(
	configuration: WeaponDefinitions.Configuration,
	magazine_index: int
) -> void:
	if not _player:
		return

	_player.loadout_manager.try_refill_magazine_rounds(
		configuration,
		magazine_index,
		1,
		_player.soulite_manager
	)
	_refresh_menu()


func _on_fill_magazine_pressed(
	configuration: WeaponDefinitions.Configuration,
	magazine_index: int
) -> void:
	if not _player:
		return

	_player.loadout_manager.try_fill_magazine(
		configuration,
		magazine_index,
		_player.soulite_manager
	)
	_refresh_menu()


func _on_close_pressed() -> void:
	close_menu()
