extends Node

# =============================================================================
# T.A.R.C. SYSTEM CORE DATA MANAGEMENT
# =============================================================================


# --- SYSTEM CONSTANTS ---
const OVER_RAD_MAX: float = 100.0
const ULTRA_VENT_RELEASE_RATE: float = 15.0


# --- LIVE STATE DATA ---
var current_over_rad: float = 0.0:
	set(value):
		current_over_rad = clamp(value, 0.0, OVER_RAD_MAX)
		emit_signal("rad_level_changed", current_over_rad)

var is_over_rad_primed: bool = false


# --- INTERCHANGEABLE ELEMENT SLOTS ---
var slot_melee_element: String = "None"
var slot_grenade_element: String = "None"
var slot_ultra_vent_element: String = "None"

# --- JUMP STATE ---
var is_gravity_jump_used: bool = false


# --- MOVEMENT TECH COOLDOWNS ---
const EARTH_COOLDOWN_MAX: float = 4.0
const WIND_COOLDOWN_MAX: float = 6.0

var earth_cooldown_timer: float = 0.0
var wind_cooldown_timer: float = 0.0


# --- ENGINE PROCESSING ---
func _process(delta: float) -> void:
	earth_cooldown_timer = max(earth_cooldown_timer - delta, 0.0)
	wind_cooldown_timer = max(wind_cooldown_timer - delta, 0.0)
