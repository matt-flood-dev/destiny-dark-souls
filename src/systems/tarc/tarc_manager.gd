extends Node
class_name TarcManager

# --- SIGNALS ---

signal over_rad_changed(new_value: float)
signal ambient_rad_changed(current: float, max_val: float)
signal ultravent_activated
signal melee_activated
signal grenade_activated


# --- CONFIGURATION & EXPORTS ---

const MELEE_COOLDOWN_MAX: float = 4.0
const GRENADE_COOLDOWN_MAX: float = 6.0
const OVER_RAD_MAX: float = 100.0
const ULTRAVENT_RELEASE_RATE: float = 15.0

@export_group("Pool Balances")
@export var max_ambient_rad: float = 100.0
@export var ambient_rad_regen_rate: float = 3.0

@export_group("Over Rad")
@export var over_rad_charge_rate: float = 1.5


# --- DATA & REFERENCES ---

var is_ultravent_primed: bool = false

var slot_melee_element: String = "None"
var slot_grenade_element: String = "None"
var slot_ultravent_element: String = "None"

var melee_cooldown_timer: float = 0.0
var grenade_cooldown_timer: float = 0.0

var current_ambient_rad: float = 100.0:
	set(value):
		var clamped: float = clampf(value, 0.0, max_ambient_rad)
		if is_equal_approx(current_ambient_rad, clamped):
			return
		current_ambient_rad = clamped
		ambient_rad_changed.emit(current_ambient_rad, max_ambient_rad)

var current_over_rad: float = 0.0:
	set(value):
		var clamped: float = clampf(value, 0.0, OVER_RAD_MAX)
		if is_equal_approx(current_over_rad, clamped):
			return
		current_over_rad = clamped
		over_rad_changed.emit(current_over_rad)


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	current_ambient_rad = max_ambient_rad

	await get_tree().process_frame
	ambient_rad_changed.emit(current_ambient_rad, max_ambient_rad)
	over_rad_changed.emit(current_over_rad)


# --- INPUT HANDLING ---

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if _is_combat_input_blocked():
		return

	if event.is_action_pressed("melee_ability"):
		activate_melee()
	elif event.is_action_pressed("grenade_ability"):
		activate_grenade()
	elif event.is_action_pressed("ultra_vent"):
		activate_ultravent()


# --- UPDATE LOOPS ---

func _process(delta: float) -> void:
	if melee_cooldown_timer > 0.0:
		melee_cooldown_timer = max(melee_cooldown_timer - delta, 0.0)

	if grenade_cooldown_timer > 0.0:
		grenade_cooldown_timer = max(grenade_cooldown_timer - delta, 0.0)

	_process_ambient_regeneration(delta)
	_process_over_rad_charge(delta)


# --- PUBLIC METHODS ---

func consume_ambient_rad(amount: float) -> bool:
	if current_ambient_rad <= 0.0:
		return false

	if current_ambient_rad >= amount:
		current_ambient_rad -= amount
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


func activate_melee() -> bool:
	if not is_melee_ready():
		return false

	start_melee_cooldown()
	melee_activated.emit()
	return true


func activate_grenade() -> bool:
	if not is_grenade_ready():
		return false

	start_grenade_cooldown()
	grenade_activated.emit()
	return true


func is_over_rad_full() -> bool:
	return is_equal_approx(current_over_rad, OVER_RAD_MAX)


func activate_ultravent() -> bool:
	if not is_over_rad_full():
		return false

	current_over_rad = 0.0
	is_ultravent_primed = false
	ultravent_activated.emit()
	DebugSettings.log("Ultravent activated!")
	return true


# --- PRIVATE METHODS ---

func _is_combat_input_blocked() -> bool:
	var player: Player = get_parent() as Player
	return player != null and player.is_checkpoint_menu_open()


func _process_ambient_regeneration(delta: float) -> void:
	if current_ambient_rad < max_ambient_rad:
		current_ambient_rad += ambient_rad_regen_rate * delta


func _process_over_rad_charge(delta: float) -> void:
	if current_over_rad < OVER_RAD_MAX:
		current_over_rad += over_rad_charge_rate * delta
