extends Node
class_name TarcManager

# --- SIGNALS ---

signal over_rad_changed(new_value: float)
signal ambient_rad_changed(current: float, max_val: float)



# --- SYSTEM CONSTANTS & CONFIG ---

const MELEE_COOLDOWN_MAX: float = 4.0
const GRENADE_COOLDOWN_MAX: float = 6.0
const OVER_RAD_MAX: float = 100.0
const ULTRAVENT_RELEASE_RATE: float = 15.0



# --- CONFIGURATION & EXPORTS ---

@export_group("Pool Balances")
@export var max_ambient_rad: float = 100.0
@export var ambient_rad_regen_rate: float = 3.0


# --- DATA & REFERENCES ---

var is_ultravent_primed: bool = false

var slot_melee_element: String = "None"
var slot_grenade_element: String = "None"
var slot_ultravent_element: String = "None"

var melee_cooldown_timer: float = 0.0
var grenade_cooldown_timer: float = 0.0

var current_ambient_rad: float = 100.0

var current_over_rad: float = 0.0:
	set(value):
		current_over_rad = clamp(value, 0.0, OVER_RAD_MAX)
		over_rad_changed.emit(current_over_rad)


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	current_ambient_rad = max_ambient_rad

	await get_tree().process_frame
	ambient_rad_changed.emit(current_ambient_rad, max_ambient_rad)


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---

func _process(delta: float) -> void:
	if melee_cooldown_timer > 0.0:
		melee_cooldown_timer = max(melee_cooldown_timer - delta, 0.0)

	if grenade_cooldown_timer > 0.0:
		grenade_cooldown_timer = max(grenade_cooldown_timer - delta, 0.0)

	_process_ambient_regeneration(delta)


# --- PUBLIC METHODS ---

func consume_ambient_rad(amount: float) -> bool:
	if current_ambient_rad <= 0.0:
		return false

	if current_ambient_rad >= amount:
		current_ambient_rad = clampf(current_ambient_rad - amount, 0.0, max_ambient_rad)
		ambient_rad_changed.emit(current_ambient_rad, max_ambient_rad)
		return true

	return false


func start_melee_cooldown() -> void:
	melee_cooldown_timer = MELEE_COOLDOWN_MAX


func start_grenade_cooldown() -> void:
	grenade_cooldown_timer = GRENADE_COOLDOWN_MAX


func is_melee_ready() -> bool:
	return melee_cooldown_timer == 0.0


func is_grenade_ready() -> bool:
	return grenade_cooldown_timer == 0.0


# --- PRIVATE METHODS ---

func _process_ambient_regeneration(delta: float) -> void:
	if current_ambient_rad < max_ambient_rad:
		current_ambient_rad = clampf(current_ambient_rad + (ambient_rad_regen_rate * delta), 0.0, max_ambient_rad)
		ambient_rad_changed.emit(current_ambient_rad, max_ambient_rad)
