extends Node
class_name TarcManager

# --- SIGNALS ---

signal rad_level_changed(new_value: float)


# --- SYSTEM CONSTANTS & CONFIG ---

const OVER_RAD_MAX: float = 100.0
const ULTRA_VENT_RELEASE_RATE: float = 15.0
const EARTH_COOLDOWN_MAX: float = 4.0
const AIR_COOLDOWN_MAX: float = 6.0


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

var is_over_rad_primed: bool = false
var is_gravity_jump_used: bool = false

var slot_melee_element: String = "None"
var slot_grenade_element: String = "None"
var slot_ultra_vent_element: String = "None"

var earth_cooldown_timer: float = 0.0
var air_cooldown_timer: float = 0.0

var current_over_rad: float = 0.0:
	set(value):
		current_over_rad = clamp(value, 0.0, OVER_RAD_MAX)
		rad_level_changed.emit(current_over_rad)


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func _process(delta: float) -> void:
	if earth_cooldown_timer > 0.0:
		earth_cooldown_timer = max(earth_cooldown_timer - delta, 0.0)
		
	if air_cooldown_timer > 0.0:
		air_cooldown_timer = max(air_cooldown_timer - delta, 0.0)


# --- PUBLIC METHODS ---

func start_earth_cooldown() -> void:
	earth_cooldown_timer = EARTH_COOLDOWN_MAX


func start_air_cooldown() -> void:
	air_cooldown_timer = AIR_COOLDOWN_MAX


func is_earth_ready() -> bool:
	return earth_cooldown_timer == 0.0


func is_air_ready() -> bool:
	return air_cooldown_timer == 0.0


# --- PRIVATE METHODS ---
