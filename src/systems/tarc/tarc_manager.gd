extends Node
class_name TarcManager

# --- SIGNALS ---

signal rad_level_changed(new_value: float)


# --- SYSTEM CONSTANTS & CONFIG ---

const MELEE_COOLDOWN_MAX: float = 4.0
const GRENADE_COOLDOWN_MAX: float = 6.0
const OVER_RAD_MAX: float = 100.0
const ULTRA_VENT_RELEASE_RATE: float = 15.0



# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

var is_over_rad_primed: bool = false
var is_gravity_jump_used: bool = false

var slot_melee_element: String = "None"
var slot_grenade_element: String = "None"
var slot_ultra_vent_element: String = "None"

var melee_cooldown_timer: float = 0.0
var grenade_cooldown_timer: float = 0.0

var current_over_rad: float = 0.0:
	set(value):
		current_over_rad = clamp(value, 0.0, OVER_RAD_MAX)
		rad_level_changed.emit(current_over_rad)


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func _process(delta: float) -> void:
	if melee_cooldown_timer > 0.0:
		melee_cooldown_timer = max(melee_cooldown_timer - delta, 0.0)

	if grenade_cooldown_timer > 0.0:
		grenade_cooldown_timer = max(grenade_cooldown_timer - delta, 0.0)


# --- PUBLIC METHODS ---

func start_melee_cooldown() -> void:
	melee_cooldown_timer = MELEE_COOLDOWN_MAX


func start_grenade_cooldown() -> void:
	grenade_cooldown_timer = GRENADE_COOLDOWN_MAX


func is_melee_ready() -> bool:
	return melee_cooldown_timer == 0.0


func is_grenade_ready() -> bool:
	return grenade_cooldown_timer == 0.0


# --- PRIVATE METHODS ---
