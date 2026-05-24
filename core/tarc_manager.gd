extends Node

# =============================================================================
# T.A.R.C. SYSTEM CORE DATA MANAGEMENT
# =============================================================================
const OVER_RAD_MAX: float = 100.0
const ULTRA_VENT_RELEASE_RATE: float = 15.0
const EARTH_COOLDOWN_MAX: float = 4.0
const WIND_COOLDOWN_MAX: float = 6.0

var current_over_rad: float = 0.0:
	set(value):
		current_over_rad = clamp(value, 0.0, OVER_RAD_MAX)
		emit_signal("rad_level_changed", current_over_rad)

var is_over_rad_primed: bool = false
var is_gravity_jump_used: bool = false

var slot_melee_element: String = "None"
var slot_grenade_element: String = "None"
var slot_ultra_vent_element: String = "None"

var earth_cooldown_timer: float = 0.0
var wind_cooldown_timer: float = 0.0


# =============================================================================
# PUBLIC API FUNCTIONS
# =============================================================================
func _process(delta: float) -> void:
	earth_cooldown_timer = max(earth_cooldown_timer - delta, 0.0)
	wind_cooldown_timer = max(wind_cooldown_timer - delta, 0.0)


func start_earth_cooldown() -> void:
	earth_cooldown_timer = EARTH_COOLDOWN_MAX
	
	
func start_wind_cooldown() -> void:
	wind_cooldown_timer = WIND_COOLDOWN_MAX
	
	
func is_earth_ready() -> bool:
	return earth_cooldown_timer == 0.0
	
	
func is_wind_ready() -> bool:
	return wind_cooldown_timer == 0.0
