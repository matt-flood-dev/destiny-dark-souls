extends PanelContainer
class_name CheckpointMenu

# --- SIGNALS ---

signal closed()


# --- CONFIGURATION & EXPORTS ---

const FRAME_OPTION_NONE: int = 0


# --- DATA & REFERENCES ---

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var soulite_label: Label = $MarginContainer/VBoxContainer/SouliteLabel
@onready var loadout_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/MenuContent/LoadoutList
@onready var magazine_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/MenuContent/MagazineList
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton

var _player: Player = null
var _is_refreshing: bool = false


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

	_is_refreshing = true
	soulite_label.text = "Soulite: " + str(_player.soulite_manager.current_soulite)
	_clear_container(loadout_list)
	_clear_container(magazine_list)
	_build_loadout_rows()
	_refresh_magazine_rows()
	_is_refreshing = false


func _refresh_magazine_rows() -> void:
	_clear_container(magazine_list)
	_build_magazine_rows()


func _build_loadout_rows() -> void:
	var section_label: Label = Label.new()
	section_label.text = "Weapon Loadout"
	loadout_list.add_child(section_label)

	for slot_index in range(WeaponDefinitions.MAX_EQUIPPED_FRAMES):
		_add_loadout_row(slot_index)


func _add_loadout_row(slot_index: int) -> void:
	var loadout_manager: LoadoutManager = _player.loadout_manager
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var slot_label: Label = Label.new()
	slot_label.text = "Slot " + str(slot_index + 1)
	slot_label.custom_minimum_size = Vector2(52, 0)
	row.add_child(slot_label)

	var frame_option: OptionButton = OptionButton.new()
	frame_option.custom_minimum_size = Vector2(120, 0)
	frame_option.add_item("None", FRAME_OPTION_NONE)

	var frame_id_map: Dictionary = {}
	var selectable_frame_id: int = 1

	for frame in WeaponDefinitions.get_all_frames():
		if not loadout_manager.is_frame_unlocked(frame):
			continue

		frame_option.add_item(WeaponDefinitions.get_frame_display_name(frame), selectable_frame_id)
		frame_id_map[selectable_frame_id] = frame
		selectable_frame_id += 1

	var current_frame: int = loadout_manager.get_slot_frame(slot_index)
	_set_frame_option_selection(frame_option, frame_id_map, current_frame)
	row.add_child(frame_option)

	var config_option: OptionButton = OptionButton.new()
	config_option.custom_minimum_size = Vector2(140, 0)
	_populate_configuration_option(config_option, current_frame, loadout_manager)
	row.add_child(config_option)

	frame_option.item_selected.connect(
		_on_frame_option_selected.bind(slot_index, frame_option, config_option, frame_id_map)
	)
	config_option.item_selected.connect(
		_on_configuration_option_selected.bind(slot_index, config_option)
	)

	loadout_list.add_child(row)


func _build_magazine_rows() -> void:
	var section_label: Label = Label.new()
	section_label.text = "Magazine Refill"
	magazine_list.add_child(section_label)

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


func _populate_configuration_option(
	config_option: OptionButton,
	frame: int,
	loadout_manager: LoadoutManager
) -> void:
	config_option.clear()

	if frame == WeaponDefinitions.SLOT_EMPTY:
		config_option.add_item("—", 0)
		config_option.disabled = true
		config_option.select(0)
		return

	config_option.disabled = false

	var config_id_map: Dictionary = {}
	var selectable_config_id: int = 0
	var unlocked_configurations: Array[WeaponDefinitions.Configuration] = (
		loadout_manager.get_unlocked_configurations_for_frame(frame as WeaponDefinitions.Frame)
	)

	for configuration in unlocked_configurations:
		config_option.add_item(
			WeaponDefinitions.get_configuration_display_name(configuration),
			selectable_config_id
		)
		config_id_map[selectable_config_id] = configuration
		selectable_config_id += 1

	if config_option.item_count <= 0:
		config_option.add_item("—", 0)
		config_option.disabled = true
		config_option.select(0)
		return

	var current_configuration: WeaponDefinitions.Configuration = loadout_manager.get_frame_configuration(
		frame as WeaponDefinitions.Frame
	)
	_set_configuration_option_selection(config_option, config_id_map, current_configuration)
	config_option.set_meta("config_id_map", config_id_map)


func _set_frame_option_selection(
	frame_option: OptionButton,
	frame_id_map: Dictionary,
	current_frame: int
) -> void:
	if current_frame == WeaponDefinitions.SLOT_EMPTY:
		frame_option.select(FRAME_OPTION_NONE)
		return

	for option_id in frame_id_map.keys():
		if frame_id_map[option_id] == current_frame:
			frame_option.select(option_id)
			return

	frame_option.select(FRAME_OPTION_NONE)


func _set_configuration_option_selection(
	config_option: OptionButton,
	config_id_map: Dictionary,
	current_configuration: WeaponDefinitions.Configuration
) -> void:
	for option_id in config_id_map.keys():
		if config_id_map[option_id] == current_configuration:
			config_option.select(option_id)
			return

	if config_option.item_count > 0:
		config_option.select(0)


func _on_frame_option_selected(
	_selected_index: int,
	slot_index: int,
	frame_option: OptionButton,
	config_option: OptionButton,
	frame_id_map: Dictionary
) -> void:
	if _is_refreshing or not _player:
		return

	var selected_id: int = frame_option.get_selected_id()
	var selected_frame: int = (
		frame_id_map[selected_id] if selected_id != FRAME_OPTION_NONE else WeaponDefinitions.SLOT_EMPTY
	)

	if not _player.loadout_manager.set_weapon_slot_frame(slot_index, selected_frame):
		_refresh_menu()
		return

	_is_refreshing = true
	_populate_configuration_option(
		config_option,
		_player.loadout_manager.get_slot_frame(slot_index),
		_player.loadout_manager
	)
	_is_refreshing = false
	_refresh_magazine_rows()


func _on_configuration_option_selected(
	_selected_index: int,
	slot_index: int,
	config_option: OptionButton
) -> void:
	if _is_refreshing or not _player:
		return

	var frame: int = _player.loadout_manager.get_slot_frame(slot_index)
	if frame == WeaponDefinitions.SLOT_EMPTY:
		return

	var config_id_map: Dictionary = config_option.get_meta("config_id_map", {})
	var selected_id: int = config_option.get_selected_id()

	if not config_id_map.has(selected_id):
		return

	var selected_configuration: WeaponDefinitions.Configuration = config_id_map[selected_id]
	var selected_frame: WeaponDefinitions.Frame = frame as WeaponDefinitions.Frame

	if _player.loadout_manager.get_frame_configuration(selected_frame) == selected_configuration:
		return

	if not _player.loadout_manager.set_frame_configuration(selected_frame, selected_configuration):
		_refresh_menu()
		return

	_refresh_magazine_rows()


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


func _clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


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
