extends Control
class_name RadarWidget

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var radar_radius: float = 58.0
@export var border_width: float = 2.0
@export var heading_height: float = 8.0
@export var heading_width: float = 9.0

@export var fill_color: Color = Color(0.07, 0.07, 0.09, 0.82)
@export var border_color: Color = Color(0.78, 0.78, 0.84, 0.92)
@export var heading_color: Color = Color(0.96, 0.96, 0.93, 1.0)


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	_update_minimum_size()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	var center: Vector2 = size * 0.5

	draw_circle(center, radar_radius, fill_color)
	draw_arc(center, radar_radius, 0.0, TAU, 72, border_color, border_width, true)

	var tip: Vector2 = center + Vector2(0.0, -heading_height)
	var bottom_left: Vector2 = center + Vector2(-heading_width * 0.5, heading_height * 0.45)
	var bottom_right: Vector2 = center + Vector2(heading_width * 0.5, heading_height * 0.45)
	draw_colored_polygon(PackedVector2Array([tip, bottom_left, bottom_right]), heading_color)


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---


# --- PRIVATE METHODS ---

func _update_minimum_size() -> void:
	var diameter: float = radar_radius * 2.0 + border_width * 2.0
	custom_minimum_size = Vector2(diameter, diameter)
