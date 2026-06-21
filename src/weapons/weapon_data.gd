class_name WeaponData
extends Resource

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var frame: WeaponDefinitions.Frame = WeaponDefinitions.Frame.PISTOL
@export var configuration: WeaponDefinitions.Configuration = WeaponDefinitions.Configuration.PISTOL_SIDEARM
@export var display_name: String = ""
@export var weapon_scene: PackedScene

@export_group("Combat")
@export var fire_rate: float = 0.0
@export var fire_cooldown_multiplier: float = 1.0
@export var reload_time: float = 0.0
@export var damage: float = 0.0

@export_group("Magazines")
@export var base_mag_capacity: int = 0
@export var starting_magazine_count: int = 0
@export var soulite_cost_per_round: int = 0

@export_group("Animations")
@export var fire_animation_name: String = ""
@export var idle_animation_name: String = ""


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---


# --- PRIVATE METHODS ---
