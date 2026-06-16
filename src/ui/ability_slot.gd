extends PanelContainer
class_name AbilitySlot

# --- CONFIGURATION & EXPORTS ---

@export var ready_color: Color = Color(0.9, 0.55, 0.12, 1.0)
@export var empty_color: Color = Color(0.1, 0.1, 0.12, 1.0)
@export var dim_color: Color = Color(0.0, 0.0, 0.0, 0.55)
@export var border_color: Color = Color(0.72, 0.72, 0.78, 0.85)


# --- DATA & REFERENCES ---

@onready var _content: Control = $SlotContent
@onready var _background: ColorRect = $SlotContent/Background
@onready var _fill: ColorRect = $SlotContent/Fill
@onready var _dim_overlay: ColorRect = $SlotContent/DimOverlay

var _charge_progress: float = 1.0


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	_apply_panel_style()
	_background.color = empty_color
	_fill.color = ready_color
	_dim_overlay.color = dim_color
	_apply_fill()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_fill()


# --- PUBLIC METHODS ---

func set_charge_progress(ratio: float) -> void:
	var clamped := clampf(ratio, 0.0, 1.0)
	if is_equal_approx(_charge_progress, clamped):
		return

	_charge_progress = clamped
	_apply_fill()


# --- PRIVATE METHODS ---

func _apply_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(1)
	add_theme_stylebox_override("panel", style)


func _apply_fill() -> void:
	if not is_node_ready():
		return

	var slot_height := _content.size.y
	if slot_height <= 0.0:
		return

	var filled_height := slot_height * _charge_progress
	var dim_height := slot_height - filled_height

	_fill.offset_left = 0.0
	_fill.offset_right = 0.0
	_fill.offset_bottom = 0.0
	_fill.offset_top = slot_height - filled_height

	_dim_overlay.offset_left = 0.0
	_dim_overlay.offset_right = 0.0
	_dim_overlay.offset_top = 0.0
	_dim_overlay.offset_bottom = dim_height
